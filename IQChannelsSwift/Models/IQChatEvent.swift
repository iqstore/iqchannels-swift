import Foundation

class IQChatEvent {
    
    var id: Int?
    var type: IQChatEventType?
    var chatId: Int?
    var isPublic: Bool?
    var transitive: Bool?
    var sessionId: Int?
    var messageId: Int?
    var memberId: Int?
    var actor: IQActorType?
    var clientId: Int?
    var userId: Int?
    var createdAt: Int?
    var messages: [IQChatMessage]?
    
    // Relations
    var client: IQClient?
    var user: IQUser?
    var chat: IQChat?
    var message: IQChatMessage?
}

extension IQChatEvent {
    
    static func fromJSONObject(_ object: Any?) -> IQChatEvent? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }

        let event = IQChatEvent()
        event.id = IQJSON.int(from: jsonObject, key: "Id")
        event.type = IQChatEventType(rawValue: IQJSON.string(from: jsonObject, key: "Type") ?? "")
        event.chatId = IQJSON.int(from: jsonObject, key: "ChatId")
        event.isPublic = IQJSON.bool(from: jsonObject, key: "IsPublic")
        event.transitive = IQJSON.bool(from: jsonObject, key: "Transitive")

        event.sessionId = IQJSON.int(from: jsonObject, key: "SessionId")
        event.messageId = IQJSON.int(from: jsonObject, key: "MessageId")
        event.memberId = IQJSON.int(from: jsonObject, key: "MemberId")

        event.actor = IQActorType(rawValue: IQJSON.string(from: jsonObject, key: "Actor") ?? "")
        event.clientId = IQJSON.int(from: jsonObject, key: "ClientId")
        event.userId = IQJSON.int(from: jsonObject, key: "UserId")

        event.messages = IQChatMessage.fromJSONArray(IQJSON.array(from: jsonObject, key: "Messages"))

        return event
    }

    static func fromJSONArray(_ array: Any?) -> [IQChatEvent] {
        guard let array = array as? [Any] else {
            return []
        }

        var events = [IQChatEvent]()
        for item in array {
            if let event = IQChatEvent.fromJSONObject(item) {
                events.append(event)
            }
        }
        return events
    }
}
