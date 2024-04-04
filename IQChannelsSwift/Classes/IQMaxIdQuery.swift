import Foundation

class IQMaxIdQuery: IQJSONEncodable {
    
    var maxId: Int?
    var limit: Int?
    
    init() { }
    
    init(maxId: Int) {
        self.maxId = maxId
    }
    
    func toJSONObject() -> [String: Any] {
        var dict = [String: Any]()
        if let maxId = self.maxId {
            dict["maxId"] = maxId
        }
        if let limit = self.limit {
            dict["limit"] = limit
        }
        return dict
    }
}
