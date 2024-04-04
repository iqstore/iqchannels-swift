import Foundation

class IQError {
    
    var code: IQErrorCode?
    var text: String?
}

extension IQError {
    
    static func fromJSONObject(_ object: Any?) -> IQError? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }

        let error = IQError()
        error.code = IQErrorCode(rawValue: IQJSON.string(from: jsonObject, key: "code") ?? "")
        error.text = IQJSON.string(from: jsonObject, key: "text")
        return error
    }
}
