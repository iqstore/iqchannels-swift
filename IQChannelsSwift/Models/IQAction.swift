import Foundation

class IQAction {
    
    var id: Int
    var chatMessageId: Int
    var clientId: Int
    var deleted: Bool
    var title: String?
    var action: String?
    var payload: String?
    var url: String?
    var createdAt: Int
    var updatedAt: Int
    
    init(id: Int, chatMessageId: Int, clientId: Int, deleted: Bool, title: String? = nil, action: String? = nil, payload: String? = nil, url: String? = nil, createdAt: Int, updatedAt: Int) {
        self.id = id
        self.chatMessageId = chatMessageId
        self.clientId = clientId
        self.deleted = deleted
        self.title = title
        self.action = action
        self.payload = payload
        self.url = url
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension IQAction {
    
    static func fromJSONObject(_ object: Any?) -> IQAction? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }
        
        let id = IQJSON.int(from: jsonObject, key: "Id") ?? 0
        let chatMessageId = IQJSON.int(from: jsonObject, key: "ChatMessageId") ?? 0
        let clientId = IQJSON.int(from: jsonObject, key: "ClientId") ?? 0
        let deleted = IQJSON.bool(from: jsonObject, key: "Deleted")
        let title = IQJSON.string(from: jsonObject, key: "Title") ?? ""
        let action = IQJSON.string(from: jsonObject, key: "Action") ?? ""
        let payload = IQJSON.string(from: jsonObject, key: "Payload") ?? ""
        let url = IQJSON.string(from: jsonObject, key: "URL") ?? ""
        let createdAt = IQJSON.int(from: jsonObject, key: "CreatedAt") ?? 0
        let updatedAt = IQJSON.int(from: jsonObject, key: "UpdatedAt") ?? 0
        
        return IQAction(id: id,
                        chatMessageId: chatMessageId,
                        clientId: clientId,
                        deleted: deleted,
                        title: title,
                        action: action,
                        payload: payload,
                        url: url,
                        createdAt: createdAt,
                        updatedAt: updatedAt)
    }
    
    static func fromJSONArray(_ array: [Any]?) -> [IQAction] {
        guard let jsonArray = array as? [[String: Any]] else {
            return []
        }
        
        var actions: [IQAction] = []
        for item in jsonArray {
            if let action = IQAction.fromJSONObject(item) {
                actions.append(action)
            }
        }
        return actions
    }
}
