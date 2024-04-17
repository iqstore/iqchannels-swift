import Foundation

protocol IQJSONDecodable {
    static func fromJSONObject(_ object: Any?) -> AnyObject?
}
