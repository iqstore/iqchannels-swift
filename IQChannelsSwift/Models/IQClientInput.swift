import Foundation

class IQClientInput: IQJSONEncodable {
    
    var name: String?
    var channel: String?
    
    init(name: String? = nil, 
         channel: String? = nil) {
        self.name = name
        self.channel = channel
    }
    
    func toJSONObject() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let name {
            dict["name"] = name
        }
        if let channel {
            dict["channel"] = channel
        }
        return dict
    }
}
