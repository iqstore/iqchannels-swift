import Foundation
import MessageKit

class IQRelationService {
    
    var address: String?
    private var calendar: Calendar
    
    init() {
        calendar = Calendar.current
    }
    
    func map(_ map: IQRelationMap) {
        chats(Array(map.chats.values), with: map)
        chatMessages(Array(map.chatMessages.values), with: map)
        clients(Array(map.clients.values), with: map)
        files(Array(map.files.values), with: map)
        users(Array(map.users.values), with: map)
    }
    
    func mapFromRelations(_ relations: IQRelations?) -> IQRelationMap {
        let map = IQRelationMap(relations: relations)
        self.map(map)
        return map
    }
    
    func chats(_ chatsToMap: [IQChat], with map: IQRelationMap) {
        for chatToMap in chatsToMap {
            chat(chatToMap, with: map)
        }
    }
    
    func chat(_ chatToMap: IQChat, with map: IQRelationMap?) {
        chatToMap.client = map?.clients[chatToMap.clientId]
        if let messageId = chatToMap.messageId {
            chatToMap.message = map?.chatMessages[messageId]
        }
        chatToMap.channel = map?.channels[chatToMap.channelId]
    }
    
    func chatMessages(_ messages: [IQChatMessage], with map: IQRelationMap?) {
        for message in messages {
            chatMessage(message, with: map)
        }
    }
    
    func chatMessage(_ message: IQChatMessage, with map: IQRelationMap?) {
        if let clientId = message.clientId { message.client = map?.clients[clientId] }
        if let userId = message.userId { message.user = map?.users[userId] }
        if let fileId = message.fileId { message.file = map?.files[fileId] }
        if let ratingId = message.ratingId { message.rating = map?.ratings[ratingId] }
        
        let createdAtTimeInterval = TimeInterval(message.createdAt) / 1000
        message.createdDate = Date(timeIntervalSince1970: createdAtTimeInterval)
        
        if let createdDate = message.createdDate {
            message.createdComponents = calendar.dateComponents([.year, .month, .day], from: createdDate)
        }
    }
    
    func chatEvents(_ events: [IQChatEvent], with map: IQRelationMap?) {
        for event in events {
            chatEvent(event, with: map)
        }
    }
    
    func chatEvent(_ event: IQChatEvent, with map: IQRelationMap?) {
        if let clientId = event.clientId { event.client = map?.clients[clientId] }
        if let userId = event.userId { event.user = map?.users[userId] }
        if let chatId = event.chatId { event.chat = map?.chats[chatId] }
        if let messageId = event.messageId { event.message = map?.chatMessages[messageId] }
    }
    
    func clients(_ clients: [IQClient], with map: IQRelationMap) {
        for client in clients {
            self.client(client, with: map)
        }
    }
    
    func client(_ client: IQClient, with map: IQRelationMap?) {
        client.senderId = jsq_clientSenderId(client.id)
        client.senderDisplayName = client.name
    }
    
    func clientAuth(_ auth: IQClientAuth, with map: IQRelationMap?) {
        if let client = auth.client {
            self.client(client, with: map)
        }
    }
    
    func files(_ files: [IQFile], with map: IQRelationMap) {
        for file in files {
            self.file(file, with: map)
        }
    }
    
    func file(_ file: IQFile?, with map: IQRelationMap?) {
        guard let file else { return }
        
        if let fileId = file.id {
            file.url = fileUrl(fileId)
            file.imagePreviewUrl = fileImageUrl(fileId, size: .preview)
        }
    }
    
    func fileUrl(_ fileId: String?) -> URL? {
        guard let fileId, let address = address else { return nil }
        var cleanedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedAddress.hasPrefix("/") {
            cleanedAddress = String(cleanedAddress.dropFirst())
        }
        if cleanedAddress.hasSuffix("/") {
            cleanedAddress = String(cleanedAddress.dropLast())
        }
        let urlString = "\(cleanedAddress)/public/api/v1/files/get/\(fileId)"
        return URL(string: urlString)
    }
    
    func fileImageUrl(_ fileId: String, size: IQFileImageSize) -> URL? {
        guard let address = address else { return nil }
        var cleanedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedAddress.hasPrefix("/") {
            cleanedAddress = String(cleanedAddress.dropFirst())
        }
        if cleanedAddress.hasSuffix("/") {
            cleanedAddress = String(cleanedAddress.dropLast())
        }
        let urlString = "\(cleanedAddress)/public/api/v1/files/image/\(fileId)?size=\(size.rawValue)"
        return URL(string: urlString)
    }
    
    func users(_ users: [IQUser], with map: IQRelationMap) {
        for user in users {
            self.user(user, with: map)
        }
    }
    
    func user(_ user: IQUser, with map: IQRelationMap) {
        user.senderId = jsq_userSenderId(user.id)
        user.senderDisplayName = user.name
        if let avatarId = user.avatarId {
            user.avatarURL = fileImageUrl(avatarId, size: .avatar)
        }
    }
    
    func jsq_clientSenderId(_ clientId: Int?) -> String {
        if let clientId {
            return "client-\(clientId)"
        } else {
            return ""
        }
    }
    
    func jsq_userSenderId(_ userId: Int?) -> String {
        if let userId {
            return "user-\(userId)"
        } else {
            return ""
        }
    }
}
