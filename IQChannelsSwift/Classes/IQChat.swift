import Foundation

class IQChat {
    
    var id: Int = 0
    var channelId: Int = 0
    var clientId: Int = 0
    var isOpen: Bool = false
    var eventId: Int?
    var messageId: Int?
    var sessionId: Int?
    var assigneeId: Int?
    var clientUnread: Int = 0
    var userUnread: Int = 0
    var totalMembers: Int = 0
    var createdAt: Int = 0
    var openedAt: Int?
    var closedAt: Int?
    
    // Relations
    var client: IQClient?
    var message: IQChatMessage?
    var channel: IQChannel?
}

extension IQChat {
    
     static func fromJSONObject(_ object: Any?) -> IQChat? {
        guard let jsonObject = object as? [String: Any] else { return nil }

        var chat = IQChat()
        chat.id = IQJSON.int(from: jsonObject, key: "Id") ?? 0
        chat.channelId = IQJSON.int(from: jsonObject, key: "ChannelId") ?? 0
        chat.clientId = IQJSON.int(from: jsonObject, key: "ClientId") ?? 0
        chat.isOpen = IQJSON.bool(from: jsonObject, key: "IsOpen")

        chat.eventId = IQJSON.int(from: jsonObject, key: "EventId")
        chat.messageId = IQJSON.int(from: jsonObject, key: "MessageId")
        chat.sessionId = IQJSON.int(from: jsonObject, key: "SessionId")
        chat.assigneeId = IQJSON.int(from: jsonObject, key: "AssigneeId")

        chat.clientUnread = IQJSON.int(from: jsonObject, key: "ClientUnread") ?? 0
        chat.userUnread = IQJSON.int(from: jsonObject, key: "UserUnread") ?? 0
        chat.totalMembers = IQJSON.int(from: jsonObject, key: "TotalMembers") ?? 0

        chat.createdAt = IQJSON.int(from: jsonObject, key: "CreatedAt") ?? 0
        chat.openedAt = IQJSON.int(from: jsonObject, key: "OpenedAt")
        chat.closedAt = IQJSON.int(from: jsonObject, key: "ClosedAt")

        return chat
    }

    static func fromJSONArray(_ array: Any?) -> [IQChat] {
        guard let jsonArray = array as? [[String: Any]] else { return [] }

        var chats = [IQChat]()
        for item in jsonArray {
            if let chat = IQChat.fromJSONObject(item) {
                chats.append(chat)
            }
        }
        return chats
    }
}
