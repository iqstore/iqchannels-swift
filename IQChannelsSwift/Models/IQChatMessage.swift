import Foundation
import UIKit
import MessageKit

class IQChatMessage: MessageType {
    
    var id: Int = 0
    var uID: String = UUID().uuidString
    var chatId: Int = 0
    var sessionId: Int = 0
    var localId: Int = 0
    var eventId: Int?
    var replyToMessageID: Int?
    var replyToMessage: IQChatMessage?
    var isPublic: Bool = false
    
    // Author
    var author: IQActorType?
    var clientId: Int?
    var userId: Int?
    
    // Payload
    var payload: IQChatPayloadType?
    var _text: String?
    var fileId: String?
    var ratingId: Int?
    var noticeId: Int?
    var botpressPayload: String?
    
    // Flags
    var received: Bool {
        uploadError == nil
    }
    /// Custom flag
    var sent: Bool = false
    var read: Bool = false
    var disableFreeText: Bool = false
    var isDropDown: Bool = false
    
    // Timestamps
    var createdAt: Int = 0
    var receivedAt: Int?
    var readAt: Int?
    
    // Transitive
    var isMy: Bool = false
    
    // Relations
    var client: IQClient?
    var user: IQUser?
    var file: IQFile?
    var rating: IQRating?
    
    var createdDate: Date?
    var createdComponents: DateComponents?
    
    // Message Kit
    var sender: SenderType {
        return MessageSender(senderId: chatMessageSenderId(),
                             displayName: chatMessageSenderDisplayName())
    }
    var messageId: String {
        return uID
    }
    var sentDate: Date {
        return createdDate ?? Date()
    }
    var kind: MessageKind {
        switch payload {
        case .text:
            return .text(text)
        case .file:
            guard let file else { return .custom(nil) }
            
            switch file.type {
            case .image:
                guard let media else { return .custom(nil) }
                return .photo(media)
            default:
                return .custom(nil)
            }
        case .singleChoice:
            if isDropDown {
                return .text(text)
            } else {
                return .custom(nil)
            }
        default:
            return .custom(nil)
        }
    }
    
    var text: String {
        if let uploadError {
            return "Ошибка: \(uploadError.localizedDescription)"
        }
        if isFileMessage {
            return "\(file!.name ?? "")"
        }
        if let rating {
            switch rating.state {
            case .pending: return "Удалось решить вопрос?\nОцените работу оператора"
            case .ignored: return "Без оценки"
            case .rated: return "Оценка принята! Спасибо, что помогаете нам стать лучше!"
            case .none, .some(.invalid):
                break
            }
        }
        return _text ?? ""
    }
    
    var isMediaMessage: Bool {
        if uploadError != nil {
            return false // Display an error message.
        }
        if uploadImage != nil {
            return true
        }
        return isImageMessage || isPendingRatingMessage
    }
    
    var isFileMessage: Bool {
        return file != nil && file!.type == .file
    }
    
    var isImageMessage: Bool {
        return file != nil && file!.type == .image
    }
    
    var isPendingRatingMessage: Bool {
        return rating != nil && rating!.state == .pending
    }
    
    var _media: MessageMediaItem?
    
    var media: MessageMediaItem? {
        if let existingMedia = _media {
            return existingMedia
        }
        
//        if isPendingRatingMessage {
//            _media = IQRatingMediaItem(rating: _Rating)
//            return _media
//        }
        
        guard isMediaMessage,
              let file else { return nil }
        
        _media = .init(url: file.url,
                       image: nil,
                       placeholderImage: .init(),
                       size: .init(width: 210, height: 150))
        return _media
    }
    
    // Local
    var uploadImage: UIImage?
    var uploadData: Data?
    var uploadFilename: String?
    var uploaded: Bool = false
    var uploading: Bool = false
    var uploadError: Error?
    
    var singleChoices: [IQSingleChoice]?
    var actions: [IQAction]?
    
    // MARK: - INIT
    init() {
        
    }
    
    init(client: IQClient?, localId: Int) {
        self.localId = localId
        self.isPublic = true
        
        // Author
        self.author = .client
        self.clientId = client?.id
        
        // Timestamps
        self.createdAt = Int(Date().timeIntervalSince1970 * 1000)
        
        // Relations
        self.isMy = true
    }

    convenience init(client: IQClient?, localId: Int, text: String?, replyToMessageID: Int?) {
        self.init(client: client, localId: localId)
        self.payload = .text
        self._text = text
        self.replyToMessageID = replyToMessageID
    }

    convenience init(client: IQClient?, localId: Int, image: UIImage, fileName: String, replyToMessageID: Int?) {
        self.init(client: client, localId: localId)
        self.payload = .file
        self.file = IQFile(image: image, filename: fileName)
        self.uploadImage = image
        self.uploadFilename = fileName
        self.replyToMessageID = replyToMessageID
    }

    convenience init(client: IQClient?, localId: Int, data: Data, fileName: String, replyToMessageID: Int?) {
        self.init(client: client, localId: localId)
        self.payload = .file
        if fileName.contains("gif") {
            self.file = IQFile(image: .init(data: data) ?? .init(), filename: fileName)
        } else {
            self.file = IQFile(data: data, filename: fileName)
        }
        self.uploadData = data
        self.replyToMessageID = replyToMessageID
        self.uploadFilename = fileName
    }
    
    // MARK: - METHODS
    private func chatMessageSenderId() -> String {
        switch author {
        case .client:
            return clientSenderId(clientId)
        case .user:
            return userSenderId(userId)
        case .system:
            return "system"
        default:
            return ""
        }
    }
    
    func chatMessageSenderDisplayName() -> String {
        switch author {
        case .client:
            if let client = client {
                return client.name ?? ""
            }
            return ""
        case .user:
            if let user = user {
                return user.name ?? ""
            }
            return ""
        default:
            return ""
        }
    }
    
    private func clientSenderId(_ clientId: Int?) -> String {
        if let clientId {
            return "client-\(clientId)"
        } else {
            return ""
        }
    }
    
    private func userSenderId(_ userId: Int?) -> String {
        if let userId {
            return "user-\(userId)"
        } else {
            return ""
        }
    }
}

extension IQChatMessage {
    
    static func fromJSONObject(_ object: Any?) -> IQChatMessage? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }
        
        let message = IQChatMessage()
        message.id = IQJSON.int(from: jsonObject, key: "Id") ?? 0
        message.uID = IQJSON.string(from: jsonObject, key: "UID") ?? UUID().uuidString
        message.chatId = IQJSON.int(from: jsonObject, key: "ChatId") ?? 0
        message.sessionId = IQJSON.int(from: jsonObject, key: "SessionId") ?? 0
        message.localId = IQJSON.int(from: jsonObject, key: "LocalId") ?? 0
        message.eventId = IQJSON.int(from: jsonObject, key: "EventId")
        message.replyToMessageID = IQJSON.int(from: jsonObject, key: "ReplyToMessageId")
        message.isPublic = IQJSON.bool(from: jsonObject, key: "Public")
        
        message.author = IQActorType(rawValue: IQJSON.string(from: jsonObject, key: "Author") ?? "")
        message.clientId = IQJSON.int(from: jsonObject, key: "ClientId")
        message.userId = IQJSON.int(from: jsonObject, key: "UserId")
        
        message.payload = IQChatPayloadType(rawValue: IQJSON.string(from: jsonObject, key: "Payload") ?? "")
        message._text = IQJSON.string(from: jsonObject, key: "Text")
        message.fileId = IQJSON.string(from: jsonObject, key: "FileId")
        message.ratingId = IQJSON.int(from: jsonObject, key: "RatingId")
        message.noticeId = IQJSON.int(from: jsonObject, key: "NoticeId")
        message.botpressPayload = IQJSON.string(from: jsonObject, key: "BotpressPayload")
        
//        message.received = IQJSON.bool(from: jsonObject, key: "Received")
        message.read = IQJSON.bool(from: jsonObject, key: "Read")
        message.disableFreeText = IQJSON.bool(from: jsonObject, key: "DisableFreeText")
        message.isDropDown = IQJSON.bool(from: jsonObject, key: "IsDropDown")
        
        message.createdAt = IQJSON.int(from: jsonObject, key: "CreatedAt") ?? 0
        message.receivedAt = IQJSON.int(from: jsonObject, key: "ReceivedAt")
        message.readAt = IQJSON.int(from: jsonObject, key: "ReadAt")
        
        message.isMy = IQJSON.bool(from: jsonObject, key: "My")
        
        message.singleChoices = IQSingleChoice.fromJSONArray(IQJSON.array(from: jsonObject, key: "SingleChoices"))
        message.actions = IQAction.fromJSONArray(IQJSON.array(from: jsonObject, key: "Actions"))
        
        return message
    }
    
    static func fromJSONArray(_ array: Any?) -> [IQChatMessage] {
        guard let jsonArray = array as? [[String: Any]] else {
            return []
        }
        
        var messages = [IQChatMessage]()
        for jsonObject in jsonArray {
            if let message = IQChatMessage.fromJSONObject(jsonObject) {
                messages.append(message)
            }
        }
        return messages
    }
}

extension IQChatMessage {
    
    func merge(with message: IQChatMessage) {
        // Ids
        id = message.id
        eventId = message.eventId

        // Payload
        payload = message.payload
        _text = message.text
        fileId = message.fileId
        noticeId = message.noticeId
        botpressPayload = message.botpressPayload

        // Relations
        client = message.client
        user = message.user
        file = message.file
    }
}
