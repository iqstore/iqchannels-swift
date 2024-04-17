import Foundation

protocol IQJSONEncodable {
    func toJSONObject() -> [String: Any]
}
