import Foundation
import UIKit

class IQUser {
    
    var id: Int = 0
    var name: String?
    var displayName: String?
    var email: String?
    var online: Bool = false
    var deleted: Bool = false
    var avatarId: String?

    var createdAt: Int = 0
    var loggedInAt: Int?
    var lastSeenAt: Int?

    // JSQ
    var senderId: String?
    var senderDisplayName: String?

    // Local
    var avatarURL: URL?
    var avatarImage: UIImage?
}

extension IQUser {
    
    static func fromJSONObject(_ object: Any?) -> IQUser? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }

        let user = IQUser()
        user.id = IQJSON.int(from: jsonObject, key: "Id") ?? 0
        user.name = IQJSON.string(from: jsonObject, key: "Name")
        user.displayName = IQJSON.string(from: jsonObject, key: "DisplayName")
        user.email = IQJSON.string(from: jsonObject, key: "Email")
        user.online = IQJSON.bool(from: jsonObject, key: "Online")
        user.deleted = IQJSON.bool(from: jsonObject, key: "Deleted")
        user.avatarId = IQJSON.string(from: jsonObject, key: "AvatarId")

        user.createdAt = IQJSON.int(from: jsonObject, key: "CreatedAt") ?? 0
        user.loggedInAt = IQJSON.int(from: jsonObject, key: "LoggedInAt")
        user.lastSeenAt = IQJSON.int(from: jsonObject, key: "LastSeenAt")

        return user
    }
    
    static func fromJSONArray(_ array: Any?) -> [IQUser] {
        guard let jsonArray = array as? [[String: Any]] else {
            return []
        }

        var users = [IQUser]()
        for jsonObject in jsonArray {
            if let user = IQUser.fromJSONObject(jsonObject) {
                users.append(user)
            }
        }
        return users
    }
}
