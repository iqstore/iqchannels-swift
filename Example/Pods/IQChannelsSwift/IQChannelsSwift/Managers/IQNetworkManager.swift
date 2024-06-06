//
//  IQNetworkManagers.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 09.05.2024.
//

import Foundation

class IQNetworkManager: IQNetworkManagerProtocol {
        
    var token: String?
    
    let address: String
    let channel: String
    var customHeaders: [String: String]?
    
    let relationManager: IQRelationManager
    var eventsListener: IQEventSourceManager?
    var unreadListener: IQEventSourceManager?
    let session = URLSession(configuration: .ephemeral)
    
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
    
    func listenToEvents(request: IQListenEventsRequest, callback: @escaping ResponseCallbackClosure<[IQChatEvent]>) {
        var path = "/sse/chats/channel/events/\(channel)"
        path += "?ChatType=\(request.chatType.rawValue)"
        if let lastEventId = request.lastEventID {
            path += "&LastEventId=\(lastEventId)"
        }
        eventsListener = sse(path: path, responseType: [IQChatEvent].self) { result, error in
            if let error = error {
                callback(nil, error)
                return
            }
            guard let result else {
                callback([], nil)
                return
            }
            
            var events = result.value ?? []
            self.relationManager.chatEvents(&events, with: result.relations)
            callback(events, nil)
        }
    }
    
    func listenToUnread(callback: @escaping ResponseCallbackClosure<Int>) {
        let path = "/sse/chats/channel/unread/\(channel)"
        unreadListener = sse(path: path, responseType: Int.self){ result, error in
            if let error = error {
                callback(nil, error)
                return
            }
            if result == nil {
                callback(nil, nil)
                return
            }
            
            callback(result?.value ?? 0, nil)
        }
    }
    
    func stopListenToEvents(){
        eventsListener = nil
    }
    
    func stopUnreadListeners(){
        unreadListener = nil
    }
    
    func pushToken(token: String) async -> Error? {
        let path = "/push/channel/apns/\(channel)"
        let params = ["Token": token]
        
        let response = await post(path, body: params, responseType: IQEmptyResponse.self)
        return response.error
    }
    
    func sendReceivedEvent(_ messageIDs: [Int]) async -> Error? {
        let path = "/chats/messages/received"
        let result = await post(path, body: messageIDs, responseType: IQEmptyResponse.self)
        return result.error
    }
    
    func sendReadEvent(_ messageIDs: [Int]) async -> Error? {
        let path = "/chats/messages/read"
        let result = await post(path, body: messageIDs, responseType: IQEmptyResponse.self)
        return result.error
    }
    
    func sendTypingEvent() async -> Error? {
        let path = "/chats/channel/typing/\(channel)"
        let result = await post(path, body: nil, responseType: IQEmptyResponse.self)
        return result.error
    }
    
    func loadMessages(request: IQLoadMessageRequest) async -> ResponseCallback<[IQMessage]> {
        let path = "/chats/channel/messages/\(channel)"
        let response = await post(path, body: request, responseType: [IQMessage].self)
        
        guard response.error == nil else { return .init(error: response.error) }
        guard let result = response.result, var value = result.value else { return .init(error: NSError.failedToParseModel([IQMessage].self)) }
        
        self.relationManager.chatMessages(&value, with: result.relations)
        return .init(result: value)
    }
    
    func rate(value: Int, ratingID: Int) async -> Error? {
        let path = "/ratings/rate"
        let params: [String: Any] = ["ratingId": ratingID, "rating": ["Value": value]]
        let response = await post(path, body: params, responseType: IQEmptyResponse.self)
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
        
        guard response.error == nil else { return .init(error: response.error) }
        guard let result = response.result, var file = result.value else { return .init(error: NSError.failedToParseModel([IQMessage].self)) }
        
        relationManager.file(&file, with: result.relations)
        return .init(result: file)
    }
    
    func sendMessage(form: IQMessageForm) async -> Error? {
        let path = "/chats/channel/send/\(channel)"
        let result = await post(path, body: form, responseType: IQEmptyResponse.self)
        return result.error
    }
    
    func clientsAuth(token: String) async -> ResponseCallback<IQClientAuth> {
        let path = "/clients/auth"
        let body = IQClientAuthRequest(token: token)
        let response = await post(path, body: body, responseType: IQClientAuth.self)
        
        guard response.error == nil else { return .init(error: response.error) }
        guard let auth = response.result?.value else { return .init(error: NSError.failedToParseModel(IQClientAuth.self)) }
        
        return .init(result: auth)
    }
    
    func clientsSignup() async -> ResponseCallback<IQClientAuth> {
        let path = "/clients/signup"
        let body = IQSignupRequest(channel: channel)
        let response = await post(path, body: body, responseType: IQClientAuth.self)
        
        guard response.error == nil else { return .init(error: response.error) }
        guard let auth = response.result?.value else { return .init(error: NSError.failedToParseModel(IQClientAuth.self)) }
        
        return .init(result: auth)
    }
    
    func clientsIntegrationAuth(credentials: String) async -> ResponseCallback<IQClientAuth> {
        let path = "/clients/integration_auth"
        let body = IQClientIntegrationAuthRequest(credentials: credentials, channel: channel)
        let response = await post(path, body: body, responseType: IQClientAuth.self)
        
        guard response.error == nil else { return .init(error: response.error) }
        guard let auth = response.result?.value else { return .init(error: NSError.failedToParseModel(IQClientAuth.self)) }
        
        return .init(result: auth)
    }
    
}
