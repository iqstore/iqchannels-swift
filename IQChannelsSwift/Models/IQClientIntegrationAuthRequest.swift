import Foundation

class IQClientIntegrationAuthRequest: IQJSONEncodable {
    
    var credentials: String?
    var channel: String?
    
    func toJSONObject() -> [String: Any] {
        var dict = [String: Any]()
        if let credentials = self.credentials {
            dict["credentials"] = credentials
        }
        if let channel = self.channel {
            dict["channel"] = channel
        }
        return dict
    }
}
