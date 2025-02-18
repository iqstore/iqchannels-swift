//
//  IQNetworkManagers.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 09.05.2024.
//

import Foundation

var unreadListeners: [IQEventSourceManager] = []

class IQNetworkManager: NSObject, IQNetworkManagerProtocol {
        
    var token: String?
    
    let address: String
    let channel: String
    var customHeaders: [String: String]?
    
    let relationManager: IQRelationManager
    var eventsListener: IQEventSourceManager?
    var unreadListener: IQEventSourceManager?
    var unreadCount: Int?
    
    lazy var session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
    
    init(address: String, channel: String) {
        self.address = address
        self.channel = channel
        self.relationManager = .init(address: address)
    }
    
    func setCustomHeaders(_ headers: [String: String]) {
        self.customHeaders = headers
    }
    
    func cancelTask(with taskIdentifier: Int) {
        Task {
            await session.allTasks.first(where: { $0.taskIdentifier == taskIdentifier } )?.cancel()
        }
    }
    
    func isConnectedToEvents() -> Bool {
        (eventsListener?.eventSource?.isOpen() ?? false)
    }
    
    static func getFileConfig(address: String) async throws -> IQFileConfig {
        let networkManager = IQNetworkManager(address: address, channel: "")
        let path = "/files/config"
        let result = await networkManager.get(path, responseType: IQFileConfig.self)
        if let value = result.result?.value {
            IQLog.debug(message: "getFileConfig: success")
            return value
        }
        let error = result.error ?? NSError.clientError()
        IQLog.error(message: "getFileConfig: \(error)")
        throw error
    }
    
    func listenToEvents(request: IQListenEventsRequest, onOpen: @escaping (() -> Void), callback: @escaping ResponseCallbackClosure<[IQChatEvent]>) {
        var path = "/sse/chats/channel/events/\(channel)"
        path += "?ChatType=\(request.chatType.rawValue)"
        if let lastEventId = request.lastEventID {
            path += "&LastEventId=\(lastEventId)"
        }
        eventsListener = sse(path: path, responseType: [IQChatEvent].self, onOpen: onOpen) { result, error in
            if let error = error {
                callback(nil, error)
                IQLog.error(message: "listenToEvents: \(error)")
                return
            }
            guard let result else {
                callback([], nil)
                return
            }
            
            var events = result.value ?? []
            
            IQLog.debug(message: "listenToEvents: \(events)")
            
            self.relationManager.chatEvents(&events, with: result.relations)
            callback(events, nil)
        }
    }
    
    func listenToUnread(callback: @escaping ResponseCallbackClosure<Int>) {
        let path = "/sse/chats/channel/unread/\(channel)"
        
        unreadListeners.forEach { $0.close() }
        unreadListeners.removeAll()
        
        unreadListener = sse(path: path, responseType: Int.self, onOpen: {} ){ result, error in
            if let error = error {
                callback(nil, error)
                IQLog.error(message: "listenToUnread: \(error)")
                return
            }
            if result == nil {
                callback(nil, nil)
                return
            }
            self.unreadCount = result?.value ?? 0
            IQLog.debug(message: "listenToUnread: \(String(describing: self.unreadCount))")
            
            callback(result?.value ?? 0, nil)
        }
        
        if let unreadListener = unreadListener {
            unreadListeners.append(unreadListener)
        }
    }
    
    func stopListenToEvents(){
        eventsListener?.close()
        eventsListener = nil
    }
    
    func stopListenToUnread(){
        unreadListener?.close()
        unreadListener = nil
    }
    
    func pushToken(token: String) async -> Error? {
        let path = "/push/channel/apns/\(channel)"
        let params = ["Token": token]
        let response = await post(path, body: params, responseType: IQEmptyResponse.self)
        
        IQLog.debug(message: "pushToken: \n token: \(token) \n response: \(response)")
        
        return response.error
    }
    
    func sendReceivedEvent(_ messageIDs: [Int]) async -> Error? {
        let path = "/chats/messages/received"
        let response = await post(path, body: messageIDs, responseType: IQEmptyResponse.self)
        
        IQLog.debug(message: "sendReceivedEvent: \n messageIDs: \(messageIDs) \n response: \(response)")
        
        return response.error
    }
    
    func sendReadEvent(_ messageIDs: [Int]) async -> Error? {
        let path = "/chats/messages/read"
        let response = await post(path, body: messageIDs, responseType: IQEmptyResponse.self)
        
        IQLog.debug(message: "sendReadEvent: \n messageIDs: \(messageIDs) \n response: \(response)")
        
        return response.error
    }
    
    func sendTypingEvent() async -> Error? {
        let path = "/chats/channel/typing/\(channel)"
        let response = await post(path, body: nil, responseType: IQEmptyResponse.self)
        
        IQLog.debug(message: "sendTypingEvent: \(response)")
        
        return response.error
    }
    
    func getFile(id: String) async throws -> IQFile? {
        let path = "/files/get_file/\(id)"
        let response = await get(path, responseType: IQFile.self)
        if let error = response.error {
            IQLog.error(message: "getFile: \(error)")
            throw error
        }
        
        IQLog.debug(message: "getFile: success")
        
        return response.result?.value
    }
    
    func openSystemChat() async -> Error? {
        let path = "/chats/channel/system_chats/send/\(channel)"
        let response = await post(path, body: nil, responseType: IQEmptyResponse.self)
        
        IQLog.debug(message: "openSystemChat: \(response)")
        
        return response.error
    }
    
    func getChatSettings(request: IQChatSettingsRequest) async -> ResponseCallback<IQChatSettings> {
        let path = "/chats/channel/chat/get_settings/\(channel)"
        let response = await post(path, body: request, responseType: IQChatSettings.self)
        
        guard response.error == nil else {
            IQLog.error(message: "getChatSettings: \n error: \(String(describing: response.error))")
            return .init(error: response.error)
        }
        guard let result = response.result, let value = result.value else { return .init(error: NSError.failedToParseModel(IQChatSettings.self)) }
        
        IQLog.debug(message: "getChatSettings: \n success")
        
        return .init(result: value)
    }
    
    func loadMessages(request: IQLoadMessageRequest) async -> ResponseCallback<([IQMessage], Bool)> {
        let path = "/chats/channel/messages/\(channel)"
        let response = await post(path, body: request, responseType: [IQMessage].self)
        
        guard response.error == nil else {
            IQLog.error(message: "loadMessages: \n request: \(request) \n error: \(String(describing: response.error))")
            return .init(error: response.error)
        }
        guard let result = response.result, var value = result.value else { return .init(error: NSError.failedToParseModel([IQMessage].self)) }
        
        let chatSettings = await getChatSettings(request: .init(clientId: request.clientId))
        
        var systemChat: Bool = false
        if let settings = chatSettings.result{
            systemChat = settings.enabled == true

            if(systemChat){
                let response = await openSystemChat()
                if (response != nil) {
                    IQLog.error(message: "openSystemChat: error: \(String(describing: response))")
                    systemChat = false
                }
            }
            
            if(settings.totalOpenedTickets == 0){
                value.append(IQMessage(
                    text: settings.message,
                    operatorName: settings.operatorName
                ))
            }
        }
        
        let unreadMessagesCount = value.filter { $0.isRead == nil && $0.author == .user}.count
        if(unreadMessagesCount > 0){
            value.insert(
                IQMessage(newMsgHeader: true),
                at: value.count - unreadMessagesCount
            )
        }
        
        self.relationManager.chatMessages(&value, with: result.relations)
        
        for message in value{
            IQDatabaseManager.shared.insertMessage(message.toDatabaseMessage())
        }
        
        IQLog.debug(message: "loadMessages: \n request: \(request) \n success")
        
        return .init(result: (value, systemChat))
    }
    
    func rate(value: Int, ratingID: Int) async -> Error? {
        let path = "/ratings/rate"
        let params: [String: Any] = ["ratingId": ratingID, "rating": ["Value": value]]
        let response = await post(path, body: params, responseType: IQEmptyResponse.self)
        
        IQLog.debug(message: "rate: \n params: \(params) \n response: \(response)")
        
        return response.error
    }
    
    func sendPoll(request: IQSendPollRequest) async -> Error? {
        let path = "/ratings/send_poll"
        let response = await post(path, body: request, responseType: IQEmptyResponse.self)
        
        IQLog.debug(message: "sendPoll: \n request: \(request) \n response: \(response)")
        
        return response.error
    }
    
    func finishPoll(ratingId: Int, pollId: Int, rated: Bool) async -> Error? {
        let path = "/ratings/finish_poll"
        let params: [String: Any] = ["RatingId": ratingId, "RatingPollId": pollId, "Rated": rated]
        let response = await post(path, body: params, responseType: IQEmptyResponse.self)
        
        IQLog.debug(message: "finishPoll: \n params: \(params) \n response: \(response)")
        
        return response.error
    }
    
    func uploadFile(file: DataFile, taskIdentifierCallback: TaskIdentifierCallback? = nil) async -> ResponseCallback<IQFile> {
        let path = "/files/upload"
        let isImage = file.filename == "image.jpeg"
        let params = [
            "Type": isImage ? "image" : "file"
        ]
        let files = [
            "File": IQFileUploadRequest(name: file.filename, data: file.data)
        ]
        
        let response = await post(path, multipart: params, files: files, taskIdentifierCallback: taskIdentifierCallback, responseType: IQFile.self)
        
        guard response.error == nil else {
            IQLog.error(message: "uploadFile: \n params: \(params) \n error: \(String(describing: response.error))")
            return .init(error: response.error)
        }
        guard let result = response.result, var file = result.value else { return .init(error: NSError.failedToParseModel([IQMessage].self)) }
        
        IQLog.debug(message: "uploadFile: \n params: \(params) \n success")
        
        relationManager.file(&file, with: result.relations)
        return .init(result: file)
    }
    
    func sendMessage(form: IQMessageForm) async -> Error? {
        let path = "/chats/channel/send/\(channel)"
        let response = await post(path, body: form, responseType: IQEmptyResponse.self)
        
        IQLog.debug(message: "sendMessage: \n form: \(form) \n result: \(response)")
        
        return response.error
    }
    
    func clientsAuth(token: String) async -> ResponseCallback<IQClientAuth> {
        let path = "/clients/auth"
        let body = IQClientAuthRequest(token: token)
        let response = await post(path, body: body, responseType: IQClientAuth.self)
        
        guard response.error == nil else {
            IQLog.error(message: "Authenticating anonymous: \n body: \(body) \n error: \(String(describing: response.error))")
            return .init(error: response.error)
        }
        guard let auth = response.result?.value else { return .init(error: NSError.failedToParseModel(IQClientAuth.self)) }
        
        IQLog.debug(message: "Authenticating anonymous: \n body: \(body) \n auth: \(auth)")
        
        return .init(result: auth)
    }
    
    func clientsSignup() async -> ResponseCallback<IQClientAuth> {
        let path = "/clients/anonymous/signup"
        let body = IQSignupRequest(channel: channel)
        let response = await post(path, body: body, responseType: IQClientAuth.self)
        
        guard response.error == nil else {
            IQLog.error(message: "clientsSignup: \n body: \(body) \n error: \(String(describing: response.error))")
            return .init(error: response.error)
        }
        guard let auth = response.result?.value else { return .init(error: NSError.failedToParseModel(IQClientAuth.self)) }
        
        IQLog.debug(message: "clientsSignup: \n body: \(body) \n auth: \(auth)")
        
        return .init(result: auth)
    }
    
    func clientsIntegrationAuth(credentials: String) async -> ResponseCallback<IQClientAuth> {
        let path = "/clients/integration_auth"
        let body = IQClientIntegrationAuthRequest(credentials: credentials, channel: channel)
        let response = await post(path, body: body, responseType: IQClientAuth.self)
        
        guard response.error == nil else {
            IQLog.error(message: "Authenticating: \n body: \(body) \n error: \(String(describing: response.error))")
            return .init(error: response.error)
        }
        guard let auth = response.result?.value else { return .init(error: NSError.failedToParseModel(IQClientAuth.self)) }
        
        IQLog.debug(message: "Authenticating: \n body: \(body) \n auth: \(auth)")
        
        return .init(result: auth)
    }
    
}
