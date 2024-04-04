import Foundation

public class IQChannelsConfig: NSObject, NSCopying, IQJSONEncodable {
    
    var address: String?
    var channel: String?
    var disableUnreadBadge: Bool = false
    
    var customHeaders: [String: String]?
    
    override init() {
        super.init()
    }
    
    public init(address: String, channel: String) {
        self.address = address
        self.channel = channel
    }
    
    func toJSONObject() -> [String: Any] {
        var jsonDict = [String: Any]()
        if let address = address {
            jsonDict["address"] = address
        }
        if let channel = channel {
            jsonDict["channel"] = channel
        }
        jsonDict["disableUnreadBadge"] = disableUnreadBadge
        return jsonDict
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = IQChannelsConfig()
        copy.channel = channel
        copy.address = address
        copy.disableUnreadBadge = disableUnreadBadge
        return copy
    }
}

extension IQChannelsConfig {
    
    static func fromJSONObject(_ object: Any?) -> IQChannelsConfig? {
        guard let jsonObject = object as? [String: Any] else { return nil }
        let config = IQChannelsConfig()
        config.address = IQJSON.string(from: jsonObject, key: "address")
        config.channel = IQJSON.string(from: jsonObject, key: "channel")
        config.disableUnreadBadge = IQJSON.bool(from: jsonObject, key: "disableUnreadBadge")
        return config
    }
}
