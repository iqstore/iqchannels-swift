import Foundation

class IQChatEventQuery: IQJSONEncodable {
    
    var lastEventId: Int?
    var limit: Int?

    init(lastEventId: Int? = nil) {
        self.lastEventId = lastEventId
    }

    func toJSONObject() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let lastEventId {
            dict["lastEventId"] = lastEventId
        }
        if let limit {
            dict["limit"] = limit
        }
        return dict
    }
}
