import Foundation

class IQChannel {
    
    var id: Int = 0
    var orgId: Int = 0
    var name: String?
    var title: String?
    var description: String?
    var deleted: Bool = false
    var eventId: Int?
    var chatEventId: Int?
    var createdAt: Int = 0
}

extension IQChannel {
    
    static func fromJSONObject(_ object: Any?) -> IQChannel? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }

        var channel = IQChannel()
        channel.id = IQJSON.int(from: jsonObject, key: "Id") ?? 0
        channel.orgId = IQJSON.int(from: jsonObject, key: "OrgId") ?? 0
        channel.name = IQJSON.string(from: jsonObject, key: "Name")
        channel.title = IQJSON.string(from: jsonObject, key: "Title")
        channel.description = IQJSON.string(from: jsonObject, key: "Description")
        channel.deleted = IQJSON.bool(from: jsonObject, key: "Deleted")
        channel.eventId = IQJSON.int(from: jsonObject, key: "EventId")
        channel.chatEventId = IQJSON.int(from: jsonObject, key: "ChatEventId")
        channel.createdAt = IQJSON.int(from: jsonObject, key: "CreatedAt") ?? 0
        return channel
    }
    
    static func fromJSONArray(_ array: Any?) -> [IQChannel] {
        guard let jsonArray = array as? [Any] else {
            return []
        }

        var channels = [IQChannel]()
        for item in jsonArray {
            if let jsonObject = item as? [String: Any], let channel = IQChannel.fromJSONObject(jsonObject) {
                channels.append(channel)
            }
        }
        return channels
    }
}
