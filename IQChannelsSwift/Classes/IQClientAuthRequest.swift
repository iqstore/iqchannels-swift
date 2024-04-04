import Foundation

class IQClientAuthRequest: IQJSONEncodable {
    
    var token: String?
    
    init(token: String? = nil) {
        self.token = token
    }
    
    func toJSONObject() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let token {
            dict["token"] = token
        }
        return dict
    }
}
