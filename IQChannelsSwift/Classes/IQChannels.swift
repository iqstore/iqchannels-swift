import Foundation
import SDWebImage
import UIKit

typealias IQFileURLCallback = (URL?, Error?) -> Void

public class IQChannels {
    
    let TYPING_DEBOUNCE_SEC = 1.5
    
    // MARK: - PROPERTIES
    private var log: IQLog?
    private var network: IQNetwork?
    private var relations: IQRelationService?
    private var client: IQHttpClient?
    private var settings: IQSettings?
    private var cache: SDImageCache?
    private var imageManager: SDWebImageManager?
    private var imageDownloading: [Int: SDWebImageOperation] = [:]
    
    private var anonymous: Bool = false
    private var credentials: String?
    private var config: IQChannelsConfig?
    
    private var state: IQChannelsState = .awaitingNetwork
    private var stateListeners: [IQChannelsStateListenerProtocol] = []
    
    private var signingUp: IQHttpRequest?
    private var signupAttempt: Int = 0
    
    private var clientAuth: IQClientAuth?
    private var authAttempt: Int = 0
    private var authing: IQHttpRequest?
    
    private var apnsToken: String?
    private var apnsSent: Bool = false
    private var apnsAttempt: Int = 0
    private var apnsSending: IQHttpRequest?
    
    private var unread: Int = 0
    private var unreadAttempt: Int = 0
    private var unreadListening: IQHttpRequest?
    private var unreadListeners: [IQChannelsUnreadListenerProtocol] = []
    
    private var messages: [IQChatMessage] = []
    private var messagesLoaded: Bool = false
    private var messagesLoading: IQHttpRequest?
    private var messageListeners: [IQChannelsMessagesListenerProtocol] = []
    
    private var eventsAttempt: Int = 0
    private var eventsListening: IQHttpRequest?
    
    private var moreMessagesLoading: IQHttpRequest?
    private var moreMessageListeners: [IQChannelsMoreMessagesListenerProtocol] = []
    
    private var receivedQueue: Set<Int> = []
    private var receivedSendAttempt: Int = 0
    private var receivedSending: IQHttpRequest?
    
    private var readQueue: Set<Int> = []
    private var readSendAttempt: Int = 0
    private var readSending: IQHttpRequest?
    
    private var typingSentAt: Date?
    private var typingRequest: IQHttpRequest?
    
    private var localId: Int = 0
    private var sendQueue: [IQChatMessage] = []
    private var sendAttempt: Int = 0
    private var sending: IQHttpRequest?
    
    private var uploading: [Int: IQHttpRequest] = [:]

    // MARK: - INIT
    init() {
        self.log = IQLog(name: "iqchannels", level: .debug)
        self.network = IQNetwork(listener: self)
        self.relations = IQRelationService()
        self.client = IQHttpClient(log: self.log, relations: self.relations, address: "")
        self.settings = IQSettings()
        self.cache = SDImageCache(namespace: "ru.iqchannels")
        self.imageManager = SDWebImageManager(cache: self.cache!,
                                              loader: SDWebImageDownloader.shared)
        
        self.stateListeners = []
        self.unreadListeners = []
        self.messageListeners = []
        self.moreMessageListeners = []
        
        self.clear()
    }
    
    // MARK: - STATE
    func unread(listener: IQChannelsUnreadListenerProtocol) -> IQSubscription {
        DispatchQueue.main.async {
            listener.iqUnreadChanged(self.unread)
        }
        
        unreadListeners.append(listener)
        return IQSubscription { [weak self] in
            self?.unreadListeners.removeAll(where: { $0.id == listener.id })
        }
    }

    // MARK: - MESSAGES
    func messages(listener: IQChannelsMessagesListenerProtocol) -> IQSubscription {
        messageListeners.append(listener)
        
        if messagesLoaded {
            let messagesCopy = messages
            DispatchQueue.main.async {
                listener.iq(messages: messagesCopy, moreMessages: false)
            }
            listenToEvents()
        } else {
            loadMessages()
        }
        
        return IQSubscription { [weak self] in
            self?.messageListeners.removeAll(where: { $0.id == listener.id })
            self?.cancelLoadingMessagesWhenNoListeners()
            self?.cancelListeningToEventsWhenNoListeners()
        }
    }
    
    // MARK: - MORE MESSAGES
    func moreMessages(_ listener: IQChannelsMoreMessagesListenerProtocol) -> IQSubscription {
        moreMessageListeners.append(listener)
        loadMoreMessages()
        
        return IQSubscription { [weak self] in
            self?.moreMessageListeners.removeAll(where: { $0.id == listener.id })
        }
    }
    
    // MARK: - MESSAGE MEDIA
    func loadMessageMedia(messageId: Int) {
        imageDownloading[messageId]?.cancel()
        imageDownloading.removeValue(forKey: messageId)
        
        guard let message = getMessageById(messageId),
              message.isMediaMessage,
              let file = message.file,
              let url = file.imagePreviewUrl,
              let media = message.media,
              media.image == nil else {
            return
        }
        
        let operation = SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { [weak self] (image, _, error, _, _, _) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.loadMessageMediaFailed(messageId: messageId, url: url, error: error)
                } else if let image = image {
                    self.loadedMessage(messageId: messageId, url: url, image: image)
                }
            }
        }
        if let operation {
            imageDownloading.updateValue(operation, forKey: messageId)
        }
        print("Loading a message image, messageId=\(messageId), url=\(url)")
    }
    
    // MARK: - TYPING
    func clearTyping() {
        typingRequest?.cancel()
        typingRequest = nil
        typingSentAt = nil
    }

    func typing() {
        guard typingRequest == nil, clientAuth != nil else { return }

        if let typingSentAt {
            let now = Date()
            let delta = now.timeIntervalSince1970 - typingSentAt.timeIntervalSince1970
            if delta < TYPING_DEBOUNCE_SEC {
                return
            }
        }

        typingSentAt = Date()
        typingRequest = client?.chatsChannel(channel: config?.channel, typing: { error in
            DispatchQueue.main.async {
                self.typingRequest = nil
            }
        })
        
        log?.debug("Typing")
    }
    
    // MARK: - SENDING
    func clearSend() {
        sending?.cancel()
        localId = 0
        sendQueue = []
        sendAttempt = 0
        sending = nil
    }

    func nextLocalId() -> Int {
        var tempLocalId = Int(Date().timeIntervalSince1970 * 1000)
        if tempLocalId < localId {
            tempLocalId = localId + 1
        }

        localId = tempLocalId
        return tempLocalId
    }

    func sendText(_ text: String) {
        guard let client = clientAuth?.client, text.count > 0 else { return }

        let localId = nextLocalId()
        let message = IQChatMessage(client: client,
                                    localId: localId,
                                    text: text)
        let map = IQRelationMap(client: client)
        relations?.chatMessage(message, with: map)

        appendMessage(message)
        sendMessage(message)

        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messageSent: message)
            }
        }
    }

    func sendImage(_ image: UIImage, fileName: String?) {
        guard let client = clientAuth?.client else { return }

        let localId = nextLocalId()
        let fileName = fileName ?? "image.jpeg"
        let message = IQChatMessage(client: client, localId: localId, image: image, fileName: fileName)
        let map = IQRelationMap(client: client)
        relations?.chatMessage(message, with: map)

        appendMessage(message)
        uploadMessage(message)

        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messageSent: message)
            }
        }
    }

    func sendData(_ data: Data, fileName: String?) {
        guard let client = clientAuth?.client else { return }

        let localId = nextLocalId()
        let fileName = fileName ?? "data"
        let message = IQChatMessage(client: client, localId: localId, data: data, fileName: fileName)
        let map = IQRelationMap(client: client)
        relations?.chatMessage(message, with: map)

        appendMessage(message)
        uploadFileMessage(message)

        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messageSent: message)
            }
        }
    }

    func sendMessage(_ message: IQChatMessage) {
        guard clientAuth != nil else { return }

        sendQueue.append(message)
        log?.debug("Enqueued a message to send, localId=\(message.localId), payload=\(message.payload ?? .invalid)")
        sendMessages()
    }

    func sendMessages() {
        guard sending == nil, clientAuth != nil, !sendQueue.isEmpty else { return }

        let message = sendQueue.removeFirst()
        let form = IQChatMessageForm(message: message)
        sendAttempt += 1

        sending = client?.chatsChannel(channel: config?.channel, form: form) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.send(message, failedWithError: error)
                    return
                }

                self.sent(form)
            }
        }

        log?.info("Sending a message, localId=\(form.localId), payload=\(form.payload ?? .invalid)")
    }

    func send(_ message: IQChatMessage, failedWithError error: Error) {
        guard sending != nil else { return }
        sending = nil
        sendQueue.insert(message, at: 0)

        if !(network?.isReachable() ?? false) {
            log?.info("Failed to send a message, network is unreachable, error=\(error.localizedDescription)")
            return
        }

        let timeout = IQTimeout.seconds(withAttempt: sendAttempt)
        let time = IQTimeout.time(withTimeoutSeconds: timeout)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.sendMessages()
        }

        log?.info("Failed to send a message, will retry \(timeout) second(s), error=\(error.localizedDescription)")
    }

    func sent(_ form: IQChatMessageForm) {
        guard sending != nil else { return }
        sending = nil

        log?.info("Sent a message, localId=\(form.localId), payload=\(form.payload ?? .invalid)")
        sendMessages()
    }

    func sendSingleChoice(_ singleChoice: IQSingleChoice) {
        guard let client = clientAuth?.client else { return }

        let localId = nextLocalId()
        let message = IQChatMessage(client: client, localId: localId, text: singleChoice.title)
        message.payload = .text
        message.botpressPayload = singleChoice.value

        let map = IQRelationMap(client: client)
        relations?.chatMessage(message, with: map)

        appendMessage(message)
        sendMessage(message)

        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messageSent: message)
            }
        }
    }

    func sendAction(_ action: IQAction) {
        guard let client = clientAuth?.client else { return }

        let localId = nextLocalId()
        let message = IQChatMessage(client: client, localId: localId, text: action.title)
        message.payload = .text
        message.botpressPayload = action.payload

        let map = IQRelationMap(client: client)
        relations?.chatMessage(message, with: map)

        appendMessage(message)
        sendMessage(message)

        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messageSent: message)
            }
        }
    }

    
    // MARK: - UPLOADING
    func clearUploading() {
        for (_, request) in uploading {
            request.cancel()
        }
        uploading.removeAll()
    }

    func retryUpload(_ localId: Int) {
        guard let message = getMyMessageByLocalId(localId), message.uploadError != nil else { return }
        uploadMessage(message)
    }

    func deleteFailedUpload(_ localId: Int) {
        guard let index = getMyMessageIndexByLocalId(localId), index != -1 else { return }
        
        _ = messages.remove(at: index)

        guard let request = uploading[localId] else { return }
        request.cancel()
        uploading.removeValue(forKey: localId)

        let updatedMessages = messages.map { $0 }
        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messages: updatedMessages, moreMessages: false)
            }
        }
    }

    func uploadMessage(_ message: IQChatMessage) {
        guard clientAuth != nil, let client else { return }
        
        let localId = message.localId
        
        guard localId != 0, let image = message.uploadImage, !message.uploaded, uploading[localId] == nil else { return }
        
        var filename = message.uploadFilename
        if filename?.isEmpty ?? true {
            filename = uploadImageDefaultFilename()
        }
        
        guard let data = image.sd_imageData(as: .JPEG, compressionQuality: 0.8) else { return }

        message.uploaded = false
        message.uploading = false
        message.uploadError = nil

        uploading[localId] = client.filesUploadImage(filename, data: data) { file, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.uploadMessage(localId, failedWithError: error)
                    return
                }
                self.uploadedMessage(localId, file: file)
            }
        }
        log?.info("Uploading a message image, localId=\(localId), fileName=\(filename ?? "")")
    }

    func uploadFileMessage(_ message: IQChatMessage) {
        guard clientAuth != nil, let client else { return }
        
        let localId = message.localId
        
        guard localId != 0, let data = message.uploadData, !message.uploaded, uploading[localId] == nil else { return }
        
        var filename = message.uploadFilename
        if filename?.isEmpty ?? true {
            filename = uploadImageDefaultFilename()
        }

        message.uploaded = false
        message.uploading = false
        message.uploadError = nil

        uploading[localId] = client.filesUploadData(filename, data: data) { file, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.uploadMessage(localId, failedWithError: error)
                    return
                }
                self.uploadedMessage(localId, file: file)
            }
        }
        log?.info("Uploading a message image, localId=\(localId), fileName=\(filename ?? "")")
    }

    func uploadImageDefaultFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        return "IMG_\(dateFormatter.string(from: Date())).jpeg"
    }

    func uploadMessage(_ localId: Int, failedWithError error: Error) {
        guard let message = getMyMessageByLocalId(localId) else { return }
        uploading.removeValue(forKey: localId)

        message.uploaded = false
        message.uploading = false
        message.uploadError = error

        log?.info("Failed to upload a message image, localId=\(localId), fileName=\(message.uploadFilename ?? ""), error=\(error.localizedDescription)")

        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messageUpdated: message)
            }
        }
    }

    func uploadedMessage(_ localId: Int, file: IQFile?) {
        guard let client = clientAuth?.client, let message = getMyMessageByLocalId(localId) else { return }
        uploading.removeValue(forKey: localId)

        message.uploaded = true
        message.uploading = false
        message.file = file
        message.fileId = file?.id
        message.uploadImage = nil
        let map = IQRelationMap(client: client)
        relations?.chatMessage(message, with: map)

        log?.info("Uploaded a message image, localId=\(localId), fileName=\(message.uploadFilename ?? ""), fileId=\(file?.id ?? "")")

        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messageUpdated: message)
            }
        }

        sendMessage(message)
    }

    // MARK: RATINGS
    func rate(ratingId: Int, value: Int) {
        _ = client?.ratingsRate(ratingId, value: value) { [weak self] error in
            if error == nil, let self,
               let index = self.messages.lastIndex(where: { $0.ratingId == ratingId }){
                self.messages[index].rating?.state = .rated
                self.messageListeners.forEach { $0.iq(messageUpdated: self.messages[index]) }
            }
        }
        log?.info("Rated \(ratingId) as \(value)")
    }

    // MARK: FILES
    func fileURL(fileId: String, callback: @escaping IQFileURLCallback) -> IQHttpRequest? {
        return client?.filesToken(fileId) { token, error in
            DispatchQueue.main.async {
                guard let token = token?.token else {
                    callback(nil, error)
                    return
                }
                let url = self.client?.fileURL(fileId, token: token)
                callback(url, nil)
            }
        }
    }
}

// MARK: - IQNetworkListener
extension IQChannels: IQNetworkListenerProtocol {
    func networkStatusChanged(_ status: IQNetworkStatus) {
        guard status != .notReachable else {
            return
        }
        
        auth()
        sendApnsToken()
        listenToUnread()
        loadMessages()
        listenToEvents()
        sendReceived()
        sendRead()
        sendMessages()
    }
}

// MARK: - PRIVATE METHODS
private extension IQChannels {
        
    // MARK: - CONFIGURE
    private func configure(_ config: IQChannelsConfig) {
        logout()
        
        self.config = config.copy() as? IQChannelsConfig
        client?.address = config.address
        relations?.address = config.address
        if let customHeaders = config.customHeaders {
            client?.setCustomHeaders(customHeaders)
            sdWebImageSetCustomHeaders(customHeaders)
        }
        log?.info("Configured, channel=\(config.channel ?? ""), address=\(config.address ?? "")")
        
        auth()
    }
    
    private func setCustomHeaders(_ headers: [String: String]) {
        client?.setCustomHeaders(headers)
        sdWebImageSetCustomHeaders(headers)
    }
    
    private func sdWebImageSetCustomHeaders(_ headers: [String: String]) {
        headers.forEach { key, value in
            SDWebImageDownloader.shared.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    private func clear() {
        self.clearSignup()
        self.clearAuth()
        self.clearApnsSending()
        self.clearUnread()
        self.clearMessages()
        self.clearMoreMessages()
        self.clearMedia()
        self.clearEvents()
        self.clearReceived()
        self.clearRead()
        self.clearSend()
        self.clearTyping()
        self.clearUploading()
    }
    
    // MARK: - STATE
    @discardableResult
    private func state(_ listener: IQChannelsStateListenerProtocol) -> IQSubscription {
        stateListeners.append(listener)
        notifyStateListener(listener)
        
        return IQSubscription { [weak self] in
            self?.stateListeners.removeAll(where: { $0.id == listener.id })
        }
    }
    
    private func setState(_ state: IQChannelsState) {
        self.state = state
        notifyStateListeners()
    }
    
    private func notifyStateListener(_ listener: IQChannelsStateListenerProtocol) {
        let state = self.state
        let client = clientAuth?.client
        
        DispatchQueue.main.async {
            switch state {
            case .loggedOut:
                listener.iqLoggedOut(state)
            case .awaitingNetwork:
                listener.iqAwaitingNetwork(state)
            case .authenticating:
                listener.iqAuthenticating(state)
            case .authenticated:
                if let client = client {
                    listener.iqAuthenticated(state, client: client)
                }
            }
        }
    }
    
    private func notifyStateListeners() {
        for listener in stateListeners {
            notifyStateListener(listener)
        }
    }
    
    private func listenToUnread() {
        guard unreadListening == nil, clientAuth != nil else { return }
        
        unreadAttempt += 1
        unreadListening = client?.chatsChannel(channel: config?.channel, callback: { [weak self] number, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.unreadError(error)
                    return
                }
                
                self.unreadEvent(number)
            }
        })
        
        log?.info("Listening to unread notifications, attempt=\(unreadAttempt)")
    }
    
    private func unreadError(_ error: Error) {
        guard unreadListening != nil else { return }
        unreadListening = nil
        
        if !(network?.isReachable() ?? false) {
            log?.info("Listening to unread failed, network is unreachable, error=\(error.localizedDescription)")
            return
        }
        
        let timeout = IQTimeout.seconds(withAttempt: unreadAttempt)
        let time = IQTimeout.time(withTimeoutSeconds: timeout)
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            self?.listenToUnread()
        }
        
        log?.info("Listening to unread failed, will retry in \(timeout) second(s), error=\(error.localizedDescription)")
    }
    
    private func unreadEvent(_ number: NSNumber?) {
        guard unreadListening != nil else { return }
        
        unreadAttempt = 0
        unread = number?.intValue ?? 0
        if !(config?.disableUnreadBadge ?? true) {
            UIApplication.shared.applicationIconBadgeNumber = unread
        }
        log?.debug("Received an unread event, unread=\(number ?? 0)")
        notifyUnreadListeners()
    }
    
    private func notifyUnreadListeners() {
        for listener in unreadListeners {
            DispatchQueue.main.async {
                listener.iqUnreadChanged(self.unread)
            }
        }
    }
    
    // MARK: - LOGIN
    private func login(_ credentials: String) {
        logout()
        anonymous = false
        self.credentials = credentials
        log?.info("Login as customer")
        auth()
    }
    
    private func loginAnonymous() {
        logout()
        anonymous = true
        log?.info("Login as anonymous")
        auth()
    }
    
    private func logout() {
        clear()
        anonymous = false
        credentials = nil
        cache?.clearMemory()
        cache?.clearDisk(onCompletion: nil)
        log?.info("Logged out")
        setState(.loggedOut)
    }
    
    // MARK: - SIGNUP
    private func clearSignup() {
        signingUp?.cancel()
        signingUp = nil
    }
    
    private func signupAnonymous() {
        guard clientAuth == nil else {
            log?.debug("Won't sign up, already authenticated")
            return
        }
        guard signingUp == nil else {
            log?.debug("Won't sign up, already signing up")
            return
        }
        guard authing == nil else {
            log?.debug("Won't sign up, already authenticating")
            return
        }
        guard let config = config else {
            log?.debug("Won't sign up, config is absent")
            return
        }
        guard network?.isReachable() ?? false else {
            log?.debug("Won't sign up, network is unreachable")
            return
        }
        
        let channel = config.channel
        signupAttempt += 1
        signingUp = client?.clientsSignup(channel: channel) { [weak self] auth, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.signupError(error)
                    return
                }
                self.signupResult(auth)
            }
        }
        
        log?.info("Signing up, attempt=\(signupAttempt)")
        setState(.authenticating)
    }
    
    private func signupError(_ error: Error?) {
        guard signingUp != nil else { return }
        signingUp = nil
        
        guard network?.isReachable() ?? false else {
            log?.info("Signup failed, network is unreachable, error=\(error?.localizedDescription ?? "")")
            return
        }
        
        let timeout = IQTimeout.seconds(withAttempt: signupAttempt)
        let time = IQTimeout.time(withTimeoutSeconds: timeout)
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            self?.signupAnonymous()
        }
        
        log?.info("Signup failed, will retry \(timeout) second(s), error=\(error?.localizedDescription ?? "")")
    }
    
    private func signupResult(_ auth: IQClientAuth?) {
        guard signingUp != nil else { return }
        
        guard let auth = auth, let client = auth.client, let session = auth.session else {
            log?.error("Signup failed, server returned an invalid auth")
            signupError(nil)
            return
        }
        
        signupAttempt = 0
        signingUp = nil
        self.clientAuth = auth
        self.client?.token = session.token
        settings?.saveAnonymousToken(session.token)
        log?.info("Signed up, clientId=\(client.id), sessionId=\(session.id ?? 0)")
        setState(.authenticated)
        
        sendApnsToken()
        listenToUnread()
        loadMessages()
    }
    
    // MARK: - AUTH
    private func clearAuth() {
        authing?.cancel()
        clientAuth = nil
        authing = nil
        authAttempt = 0
        client?.token = nil
    }
    
    private func auth() {
        guard clientAuth == nil else {
            log?.debug("Won't auth, already authenticated")
            return
        }
        guard authing == nil else {
            log?.debug("Won't auth, already authenticating")
            return
        }
        guard let config = config else {
            log?.debug("Won't auth, config is absent")
            return
        }
        guard network?.isReachable() ?? false else {
            log?.debug("Won't auth, network is unreachable")
            return
        }
        
        if anonymous {
            if let token = settings?.loadAnonymousToken() {
                authAttempt += 1
                authing = client?.clientsAuth(token: token) { [weak self] auth, error in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        if let error = error {
                            self.authError(error)
                            return
                        }
                        self.authResult(auth)
                    }
                }
                
                log?.info("Authenticating as anonymous, attempt=\(authAttempt)")
            } else {
                log?.debug("Won't auth, anonymous token is absent")
                signupAnonymous()
            }
        } else {
            guard let credentials = credentials else {
                log?.debug("Won't auth, credentials are absent")
                return
            }
            
            let channel = config.channel
            authAttempt += 1
            authing = client?.clientsIntegrationAuth(credentials: credentials, channel: channel) { [weak self] auth, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let error = error {
                        self.authError(error)
                        return
                    }
                    self.authResult(auth)
                }
            }
            
            log?.info("Authenticating as customer, channel=\(channel ?? ""), attempt=\(authAttempt)")
        }
        
        setState(.authenticating)
    }
    
    private func authError(_ error: Error?) {
        guard authing != nil else { return }
        authing = nil
        
        guard network?.isReachable() ?? false else {
            log?.info("Authentication failed, network is unreachable, error=\(error?.localizedDescription ?? "")")
            return
        }
        
        if error?.iqIsAuthError() ?? false {
            log?.info("Authentication failed, invalid anonymous token")
            signupAnonymous()
            return
        }
        
        let timeout = IQTimeout.seconds(withAttempt: authAttempt)
        let time = IQTimeout.time(withTimeoutSeconds: timeout)
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            self?.auth()
        }
        
        log?.info("Authentication failed, will retry \(timeout) second(s), error=\(error?.localizedDescription ?? "")")
    }
    
    private func authResult(_ auth: IQClientAuth?) {
        guard authing != nil else { return }
        
        guard let auth = auth, let client = auth.client, let session = auth.session else {
            log?.error("Authentication failed, server returned an invalid auth")
            authError(nil)
            return
        }
        
        clientAuth = auth
        authAttempt = 0
        authing = nil
        self.client?.token = session.token
        log?.info("Authenticated, clientId=\(client.id), sessionId=\(session.id ?? 0)")
        setState(.authenticated)
        
        sendApnsToken()
        listenToUnread()
        loadMessages()
    }
    
    // MARK: - APNS
    private func clearApnsSending() {
        if let apnsSending = apnsSending {
            apnsSending.cancel()
            self.apnsSending = nil
        }
        apnsSent = false
    }
    
    private func pushToken(_ token: Data?) {
        clearApnsSending()
        
        guard let token = token else {
            apnsToken = nil
            return
        }
        
        apnsToken = pushTokenToString(token)
        sendApnsToken()
    }
    
    private func pushTokenToString(_ deviceToken: Data) -> String {
        var token = ""
        deviceToken.forEach { byte in
            token += String(format: "%02.2hhX", byte)
        }
        return token
    }
    
    private func sendApnsToken() {
        guard let apnsToken = apnsToken, !apnsSent, apnsSending == nil else {
            return
        }
        
        apnsAttempt += 1
        apnsSending = client?.pushChannel(config?.channel, apnsToken: apnsToken) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.sendApnsTokenError(error)
                    return
                }
                self.sendApnsToken()
            }
        }
    }
    
    private func sendApnsTokenError(_ error: Error) {
        guard apnsSending != nil else {
            return
        }
        self.apnsSending = nil
        
        guard network?.isReachable() ?? false else {
            log?.info("Sending APNS token failed, network is unreachable, error=\(error.localizedDescription)")
            return
        }
        
        let timeout = IQTimeout.seconds(withAttempt: unreadAttempt)
        let time = IQTimeout.time(withTimeoutSeconds: timeout)
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            self?.sendApnsToken()
        }
        
        log?.info("Sending APNS token failed, will retry in \(timeout) second(s), error=\(error.localizedDescription)")
    }
    
    private func sentApnsToken() {
        guard apnsSending != nil else {
            return
        }
        self.apnsSending = nil
        apnsSent = true
        
        log?.info("Sent APNS token")
    }
    
    private func clearUnread() {
        unreadListening?.cancel()
        
        unread = 0
        unreadAttempt = 0
        unreadListening = nil
        if !(config?.disableUnreadBadge ?? true) {
            UIApplication.shared.applicationIconBadgeNumber = unread
        }
        
        notifyUnreadListeners()
    }
    
    // MARK: - MESSAGES
    private func clearMessages() {
        messagesLoading?.cancel()
        
        localId = 0
        messages = []
        messagesLoaded = false
        messagesLoading = nil
        
        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iqMessagesCleared()
            }
        }
    }
    
    private func cancelLoadingMessagesWhenNoListeners() {
        if !messageListeners.isEmpty {
            return
        }
        
        messagesLoading?.cancel()
        messagesLoading = nil
    }
    
    private func loadMessages() {
        guard !messagesLoaded, messagesLoading == nil, clientAuth != nil, !messageListeners.isEmpty else { return }
        
        let query = IQMaxIdQuery()
        messagesLoading = client?.chatsChannel(channel: config?.channel, query: query) { [weak self] messages, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.messagesError(error)
                    return
                }
                
                self.messagesLoaded(messages ?? [])
            }
        }
        
        log?.info("Loading messages")
    }
    
    private func messagesError(_ error: Error) {
        guard messagesLoading != nil else { return }
        
        messagesLoading = nil
        messages = []
        log?.info("Failed to load messages, error=\(error.localizedDescription)")
        
        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messagesError: error)
            }
        }
        messageListeners.removeAll()
    }
    
    private func messagesLoaded(_ messages: [IQChatMessage]) {
        guard messagesLoading != nil else { return }
        
        self.messagesLoading = nil
        messagesLoaded = true
        appendMessages(messages)
        log?.info("Loaded messages, count=\(messages.count)")
        
        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messages: messages, moreMessages: false)
            }
        }
        
        listenToEvents()
    }
    
    private func appendMessages(_ messages: [IQChatMessage]) {
        for message in messages {
            appendMessage(message)
        }
    }
    
    private func appendMessage(_ message: IQChatMessage) {
        let index = getMessageIndexById(message.id)
        guard let index, index < 0 else { return }
        
        messages.append(message)
        enqueueReceived(message)
    }
    
    private func prependMessages(_ messages: [IQChatMessage]) {
        guard !messages.isEmpty else { return }
        
        for message in messages.reversed() {
            prependMessage(message)
        }
    }
    
    private func prependMessage(_ message: IQChatMessage) {
        let index = getMessageIndexById(message.id)
        guard let index, index < 0 else { return }
        
        messages.insert(message, at: 0)
        enqueueReceived(message)
    }
    
    private func messageCreated(_ event: IQChatEvent) {
        guard let message = event.message else { return }
        
        if let existing = getMyMessageByLocalId(message.localId) {
            existing.merge(with: message)
            
            for listener in messageListeners {
                DispatchQueue.main.async {
                    listener.iq(messageUpdated: existing)
                }
            }
        } else {
            appendMessage(message)
            
            for listener in messageListeners {
                DispatchQueue.main.async {
                    listener.iq(messageAdded: message)
                }
            }
        }
    }
    
    private func messageReceived(_ event: IQChatEvent) {
        guard let messageId = event.messageId, let message = getMessageById(messageId) else { return }
        
        if message.eventId ?? 0 > event.id ?? 0 {
            return
        }
        
        message.eventId = event.id
        message.received = true
        message.receivedAt = event.createdAt
        
        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messageUpdated: message)
            }
        }
    }
    
    private func messageRead(_ event: IQChatEvent) {
        guard let messageId = event.messageId, let message = getMessageById(messageId) else { return }
        
        if message.eventId ?? 0 > event.id ?? 0 {
            return
        }
        
        message.eventId = event.id
        message.read = true
        message.readAt = event.createdAt
        if !message.received {
            message.received = true
            message.receivedAt = event.createdAt
        }
        
        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messageUpdated: message)
            }
        }
    }
    
    private func messageTyping(_ event: IQChatEvent) {
        guard event.actor != .client else { return }
        
        if let id1 = getMessageById(event.messageId)?.eventId,
           let id2 = event.id,
           id1 > id2{
            return
        }
        
        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messageTyping: event.user)
            }
        }
    }
    
    private func messagesRemoved(_ event: IQChatEvent) {
        guard let messages = event.messages else { return }
        
        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messagesRemoved: messages)
            }
        }
    }
    
    private func getMessageById(_ messageId: Int?) -> IQChatMessage? {
        guard let index = getMessageIndexById(messageId), index != -1 else { return nil }
        return messages[index]
    }
    
    private func getMessageIndexById(_ messageId: Int?) -> Int? {
        guard messageId != 0 else { return -1 }
        
        for (index, message) in messages.enumerated() {
            if message.id == messageId {
                return index
            }
        }
        return -1
    }
    
    private func getMyMessageByLocalId(_ localId: Int) -> IQChatMessage? {
        guard let index = getMyMessageIndexByLocalId(localId), index != -1 else { return nil }
        return messages[index]
    }
    
    private func getMyMessageIndexByLocalId(_ localId: Int) -> Int? {
        for (index, message) in messages.reversed().enumerated() {
            if message.isMy && message.localId == localId {
                return messages.count - 1 - index
            }
        }
        return -1
    }
    
    // MARK: - MORE MESSAGES
    private func clearMoreMessages() {
        moreMessagesLoading?.cancel()
        moreMessagesLoading = nil
        
        moreMessageListeners.forEach { $0.iqMoreMessagesLoaded() }
        moreMessageListeners.removeAll()
    }
    
    private func loadMoreMessages() {
        guard clientAuth != nil, messagesLoaded else {
            for listener in moreMessageListeners {
                DispatchQueue.main.async {
                    listener.iqMoreMessagesLoaded()
                }
            }
            moreMessageListeners.removeAll()
            return
        }
        guard moreMessagesLoading == nil else { return }
        
        let query = IQMaxIdQuery()
        for message in messages {
            if message.id == 0 {
                continue
            }
            query.maxId = message.id
            break
        }
        
        moreMessagesLoading = client?.chatsChannel(channel: config?.channel, query: query) { [weak self] messages, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.moreMessagesError(error)
                    return
                }
                
                self?.moreMessagesLoaded(messages ?? [])
            }
        }
        log?.info("Loading more messages, maxMessageId=\(query.maxId ?? 0)")
    }
    
    private func moreMessagesError(_ error: Error) {
        guard moreMessagesLoading != nil else { return }
        self.moreMessagesLoading = nil
        log?.info("Failed to load more messages, error=\(error.localizedDescription)")
        
        for listener in moreMessageListeners {
            DispatchQueue.main.async {
                listener.iqMoreMessagesError(error)
            }
        }
        moreMessageListeners.removeAll()
    }
    
    private func moreMessagesLoaded(_ moreMessages: [IQChatMessage]) {
        guard moreMessagesLoading != nil else { return }
        
        self.moreMessagesLoading = nil
        prependMessages(moreMessages)
        log?.info("Loaded more messages, count=\(moreMessages.count), total=\(messages.count)")
        
        for listener in moreMessageListeners {
            DispatchQueue.main.async {
                listener.iqMoreMessagesLoaded()
            }
        }
        moreMessageListeners.removeAll()
        
        let messagesCopy = messages
        for listener in messageListeners {
            DispatchQueue.main.async {
                listener.iq(messages: messagesCopy, moreMessages: true)
            }
        }
    }
    
    // MARK: - MESSAGE DATA
    private func clearMedia() {
        for operation in imageDownloading.values {
            operation.cancel()
        }
        imageDownloading.removeAll()
    }
    
    private func loadMessageMediaFailed(messageId: Int, url: URL, error: Error) {
        imageDownloading.removeValue(forKey: messageId)
        print("Failed to load a message image, messageId=\(messageId), url=\(url), error=\(error.localizedDescription)")
    }
    
    private func loadedMessage(messageId: Int, url: URL, image: UIImage) {
        guard let message = getMessageById(messageId),
              let media = message.media,
              media.image == nil else {
            return
        }
        
        message._media?.image = image
        message._media?.setAppropriateSizeForImage()
        imageDownloading.removeValue(forKey: messageId)
        print("Loaded a message image, messageId=\(messageId), url=\(url)")
        
        for listener in messageListeners {
            listener.iq(messageUpdated: message)
        }
    }
    
    // MARK: - EVENTS
    private func clearEvents() {
        eventsListening?.cancel()
        eventsListening = nil
        eventsAttempt = 0
    }
    
    private func cancelListeningToEventsWhenNoListeners() {
        if messageListeners.count > 0 {
            return
        }
        clearEvents()
    }
    
    private func listenToEvents() {
        guard eventsListening == nil,
              clientAuth != nil,
              messagesLoaded,
              (network?.isReachable() ?? false) else {
            return
        }
        
        let query = IQChatEventQuery()
        for message in messages where message.eventId ?? 0 > query.lastEventId ?? 0 {
            query.lastEventId = message.eventId
        }
        
        eventsAttempt += 1
        eventsListening = client?.chatsChannel(channel: config?.channel, query: query) { [weak self] (events, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.eventsError(error)
                } else {
                    self.eventsReceived(events ?? [])
                }
            }
        }
        
        print("Listening to chat events, attempt=\(eventsAttempt)")
    }
    
    private func eventsError(_ error: Error) {
        guard let eventsListening = eventsListening else {
            return
        }
        eventsListening.cancel()
        self.eventsListening = nil
        
        if !(network?.isReachable() ?? false) {
            print("Listening to chat events failed, network is unreachable, error=\(error.localizedDescription)")
            return
        }
        
        let timeout = IQTimeout.seconds(withAttempt: eventsAttempt)
        let time = IQTimeout.time(withTimeoutSeconds: timeout)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.listenToEvents()
        }
        
        print("Listening to chat events failed, will retry in \(timeout) second(s), error=\(error.localizedDescription)")
    }
    
    private func eventsReceived(_ events: [IQChatEvent]) {
        eventsAttempt = 0
        print("Received chat events, count=\(events.count)")
        applyEvents(events)
    }
    
    private func applyEvents(_ events: [IQChatEvent]) {
        for event in events {
            applyEvent(event)
        }
    }
    
    private func applyEvent(_ event: IQChatEvent) {
        let type = event.type
        
        if type == .messageCreated {
            messageCreated(event)
        } else if type == .messageReceived {
            messageReceived(event)
        } else if type == .messageRead {
            messageRead(event)
        } else if type == .typing {
            messageTyping(event)
        } else if type == .deleteMessages {
            messagesRemoved(event)
        }
    }
    
    // MARK: - MARK AS RECEIVED
    private func clearReceived() {
        receivedSending?.cancel()
        receivedQueue.removeAll()
        receivedSendAttempt = 0
    }

    private func enqueueReceived(_ message: IQChatMessage) {
        guard message.id != 0, !message.isMy, !message.received else { return }
        receivedQueue.insert(message.id)
        sendReceived()
    }

    private func sendReceived() {
        guard receivedSending == nil, clientAuth != nil, receivedQueue.count != 0 else { return }
        var messageIds = Array(receivedQueue)
        messageIds.sort()
        receivedQueue.removeAll()
        receivedSendAttempt += 1
        
        receivedSending = client?.chatsMessagesReceived(messageIds) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.sendReceivedFailed(messageIds: messageIds, error: error)
                    return
                }
                self?.sentReceived(messageIds: messageIds)
            }
        }
        
        log?.info("Sending received message ids, attempt=\(receivedSendAttempt), count=\(messageIds.count)")
    }

    private func sendReceivedFailed(messageIds: [Int], error: Error) {
        receivedSending = nil
        receivedQueue.formUnion(messageIds)
        guard network?.isReachable() ?? false else {
            log?.info("Failed to send received message ids, network is unreachable, error=\(error.localizedDescription)")
            return
        }
        let timeout = IQTimeout.seconds(withAttempt: receivedSendAttempt)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) { [weak self] in
            self?.sendReceived()
        }
        log?.info("Failed to send received message ids, will retry \(timeout) second(s), error=\(error.localizedDescription)")
    }

    private func sentReceived(messageIds: [Int]) {
        receivedSending = nil
        receivedSendAttempt = 0
        log?.info("Sent received message ids, count=\(messageIds.count)")
        sendReceived()
    }

    // MARK: MARK AS READ
    private func clearRead() {
        readSending?.cancel()
        readQueue.removeAll()
        readSendAttempt = 0
    }

    private func markAsRead(_ messageId: Int) {
        guard let message = getMessageById(messageId) else { return }
        enqueueRead(message)
    }

    private func enqueueRead(_ message: IQChatMessage) {
        guard !message.read, !message.isMy else { return }
        readQueue.insert(message.id)
        sendRead()
    }

    private func sendRead() {
        guard readSending == nil, clientAuth != nil, readQueue.count != 0 else { return }
        var messageIds = Array(readQueue)
        messageIds.sort()
        readQueue.removeAll()
        readSendAttempt += 1
        
        readSending = client?.chatsMessagesRead(messageIds) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.sendReadFailed(messageIds: messageIds, error: error)
                    return
                }
                self?.sentRead(messageIds: messageIds)
            }
        }
        
        log?.info("Send read message ids, attempt=\(readSendAttempt), count=\(messageIds.count)")
    }

    private func sendReadFailed(messageIds: [Int], error: Error) {
        readSending = nil
        readQueue.formUnion(messageIds)
        guard network?.isReachable() ?? false else {
            log?.info("Failed to send read message ids, network is unreachable, error=\(error.localizedDescription)")
            return
        }
        let timeout = IQTimeout.seconds(withAttempt: readSendAttempt)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) { [weak self] in
            self?.sendRead()
        }
        log?.info("Failed to send read message ids, will retry \(timeout) second(s), error=\(error.localizedDescription)")
    }

    private func sentRead(messageIds: [Int]) {
        guard readSending != nil else { return }
        
        readSending = nil
        readSendAttempt = 0
        log?.info("Sent read message ids, count=\(messageIds.count)")
        sendRead()
    }
}

// MARK: - STATIC METHODS
extension IQChannels {
    
    static let instance: IQChannels = {
        return IQChannels()
    }()

    public static func configure(_ config: IQChannelsConfig) {
        instance.configure(config)
    }

    public static func setCustomHeaders(_ headers: [String: String]) {
        instance.setCustomHeaders(headers)
    }

    static func pushToken(_ token: Data) {
        instance.pushToken(token)
    }

    static func state(_ listener: IQChannelsStateListenerProtocol) -> IQSubscription {
        instance.state(listener)
    }

    public static func login(_ credentials: String) {
        instance.login(credentials)
    }

    public static func loginAnonymous() {
        instance.loginAnonymous()
    }

    static func logout() {
        instance.logout()
    }

    static func unread(_ listener: IQChannelsUnreadListenerProtocol) -> IQSubscription {
        instance.unread(listener: listener)
    }

    static func messages(_ listener: IQChannelsMessagesListenerProtocol) -> IQSubscription {
        instance.messages(listener: listener)
    }

    static func moreMessages(_ listener: IQChannelsMoreMessagesListenerProtocol) -> IQSubscription {
        instance.moreMessages(listener)
    }

    static func loadMessageMedia(_ messageId: Int) {
        instance.loadMessageMedia(messageId: messageId)
    }

    static func typing() {
        instance.typing()
    }

    static func sendText(_ text: String) {
        instance.sendText(text)
    }

    static func sendImage(_ image: UIImage, filename: String?) {
        instance.sendImage(image, fileName: filename)
    }

    static func sendData(_ data: Data, filename: String?) {
        instance.sendData(data, fileName: filename)
    }

    static func retryUpload(_ localId: Int) {
        instance.retryUpload(localId)
    }

    static func deleteFailedUpload(_ localId: Int) {
        instance.deleteFailedUpload(localId)
    }

    static func markAsRead(_ messageId: Int) {
        instance.markAsRead(messageId)
    }

    static func rate(_ ratingId: Int, value: Int) {
        instance.rate(ratingId: ratingId, value: value)
    }

    static func fileURL(_ fileId: String, callback: @escaping IQFileURLCallback) -> IQHttpRequest? {
        instance.fileURL(fileId: fileId, callback: callback)
    }

    static func sendSingleChoice(_ singleChoice: IQSingleChoice) {
        instance.sendSingleChoice(singleChoice)
    }

    static func sendAction(_ action: IQAction) {
        instance.sendAction(action)
    }
}
