import Foundation

class IQJSON {
    
    static func object(with data: Data) throws -> Any {
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
    
    static func string(from object: [String: Any]?, key: String) -> String? {
        guard let object = object else { return nil }
        guard let val = object[key] as? String else { return nil }
        return val
    }
    
    static func int(from object: [String: Any]?, key: String) -> Int? {
        guard let object = object else { return nil }
        guard let val = object[key] as? Int else { return nil }
        return val
    }
    
    static func bool(from object: [String: Any]?, key: String) -> Bool {
        guard let object = object else { return false }
        guard let val = object[key] as? Bool else { return false }
        return val
    }
    
    static func dict(from object: [String: Any]?, key: String) -> [String: Any]? {
        guard let object = object else { return nil }
        guard let val = object[key] as? [String: Any] else { return nil }
        return val
    }
    
    static func array(from object: [String: Any]?, key: String) -> [Any]? {
        guard let object = object else { return nil }
        guard let val = object[key] as? [Any] else { return nil }
        return val
    }
}
