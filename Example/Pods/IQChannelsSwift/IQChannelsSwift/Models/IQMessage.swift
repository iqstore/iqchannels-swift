//
//  IQMessage.swift
//  Pods
//
//  Created by Muhammed Aralbek on 12.05.2024.
//  
//

import Foundation

struct IQMessage: Codable, Identifiable, Equatable {
    
    //MARK: - Server side
    var messageID: Int = 0
    var localID: Int?
    var fileID: String?
    var createdAt: Int?
    var eventID: Int?
    var userID: Int?
    var clientID: Int?
    var ratingID: Int?
    var payload: IQMessagePayloadType?
    var text: String?
    var isMy: Bool?
    var author: IQAuthorType?
    var isRead: Bool?
    var replyToMessageID: Int?
    var botpressPayload: String?
    var isDropDown: Bool?
    var disableFreeText: Bool?
    var actions: [IQAction]?
    var singleChoices: [IQSingleChoice]?
    
    enum CodingKeys: String, CodingKey {
        case messageID = "id"
        case isMy = "my"
        case isRead = "read"
        case payload, text, userID, clientID, fileID, createdAt, localID, eventID, isDropDown, singleChoices, actions, replyToMessageID, botpressPayload, disableFreeText, ratingID, author
    }

    //MARK: - Custom
    /// ID for UI, dont use
    var id: String = UUID().uuidString
    var chatType: IQChatType?
    
    //MARK: - Relations
    var client: IQClient?
    var user: IQUser?
    var file: IQFile?
    var rating: IQRating?

    //MARK: - Computed
    var createdDate: Date {
        if let createdAt {
            return Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000)
        }
        
        return Date()
    }
    
    var isSent: Bool {
        messageID != 0
    }
    
    /// For File messages see IQFile.isLoading
    var isLoading: Bool {
        !isSent && !(isRead ?? false)
    }
    
    var isPendingRatingMessage: Bool {
        return rating?.state == .pending
    }
    
    var isMessageReplied: Bool {
        return replyToMessageID != nil
    }
    
    var hasValidPayload: Bool {
        payload != nil && payload != .invalid
    }
    
    var senderName: String {
        switch author {
        case .anonymous:
            return "Аноним"
        case .client:
            return client?.name ?? ""
        case .user:
            return user?.displayName ?? ""
        case .system:
            return "Система"
        case nil:
            return ""
        }
    }
    
    var messageText: String {
        if let file {
            switch file.type {
            case .file: return file.name ?? ""
            case .image: return "Фотография"
            default: return ""
            }
        }
        
        if let rating {
            switch rating.state {
            case .pending: return "Удалось решить вопрос?\nОцените работу оператора"
            case .ignored: return "Без оценки"
            case .rated: return "Оценка принята! Спасибо, что помогаете нам стать лучше!"
            default: return ""
            }
        }
        
        if payload == nil || payload == .invalid {
            return "Неподдерживаемый тип сообщения"
        }
        
        return text ?? ""
    }
    
    //MARK: - INIT
    init(text: String, chatType: IQChatType, localID: Int, replyMessageID: Int?) {
        self.init(localID: localID, chatType: chatType, replyMessageID: replyMessageID)
        self.text = text
        self.payload = .text
    }
    
    init(dataFile: DataFile, chatType: IQChatType, localID: Int, replyMessageID: Int?) {
        self.init(localID: localID, chatType: chatType, replyMessageID: replyMessageID)
        self.payload = .file
        self.file = IQFile(dataFile: dataFile)
    }
    
    init(action: IQAction, chatType: IQChatType, localID: Int) {
        self.init(localID: localID, chatType: chatType, replyMessageID: nil)
        self.payload = .text
        self.text = action.title
        self.botpressPayload = action.payload
    }
    
    init(choice: IQSingleChoice, chatType: IQChatType, localID: Int) {
        self.init(localID: localID, chatType: chatType, replyMessageID: nil)
        self.payload = .text
        self.text = choice.title
        self.botpressPayload = choice.value
    }
    
    private init(localID: Int, chatType: IQChatType, replyMessageID: Int?) {
        self.isMy = true
        self.replyToMessageID = replyMessageID
        self.createdAt = Int(Date().timeIntervalSince1970 * 1000)
        self.localID = localID
        self.chatType = chatType
    }
    
    //MARK: - Methods
    
    mutating func merged(with message: IQMessage) -> IQMessage {
        var copy = self
        // Ids
        copy.messageID = message.messageID
        copy.eventID = message.eventID

        // Payload
        copy.payload = message.payload
        copy.text = message.text
        copy.fileID = message.fileID
        copy.replyToMessageID = message.replyToMessageID
        copy.botpressPayload = message.botpressPayload
        copy.author = message.author

        // Relations
        copy.user = message.user
        copy.client = message.client
        copy.file = message.file
        
        return copy
    }

}
