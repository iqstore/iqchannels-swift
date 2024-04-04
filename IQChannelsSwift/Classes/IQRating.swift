import Foundation

class IQRating {
    
    var id: Int = 0
    var projectId: Int = 0
    var ticketId: Int = 0
    var userId: Int = 0

    var state: IQRatingState?
    var value: Int?
    var comment: String?

    var createdAt: Int = 0
    var updatedAt: Int = 0
}

extension IQRating {
    
    static func fromJSONObject(_ object: Any?) -> IQRating? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }

        let rating = IQRating()
        rating.id = IQJSON.int(from: jsonObject, key: "Id") ?? 0
        rating.projectId = IQJSON.int(from: jsonObject, key: "ProjectId") ?? 0
        rating.ticketId = IQJSON.int(from: jsonObject, key: "TicketId") ?? 0
        rating.userId = IQJSON.int(from: jsonObject, key: "UserId") ?? 0

        rating.state = IQRatingState(rawValue: IQJSON.string(from: jsonObject, key: "State") ?? "")
        rating.value = IQJSON.int(from: jsonObject, key: "Value")
        rating.comment = IQJSON.string(from: jsonObject, key: "Comment")

        rating.createdAt = IQJSON.int(from: jsonObject, key: "CreatedAt") ?? 0
        rating.updatedAt = IQJSON.int(from: jsonObject, key: "UpdatedAt") ?? 0

        return rating
    }

    static func fromJSONArray(_ array: Any?) -> [IQRating] {
        guard let jsonArray = array as? [[String: Any]] else {
            return []
        }

        var ratings = [IQRating]()
        for jsonObject in jsonArray {
            if let rating = IQRating.fromJSONObject(jsonObject) {
                ratings.append(rating)
            }
        }
        return ratings
    }
}
