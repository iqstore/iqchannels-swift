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
        error.code = IQErrorCode(rawValue: IQJSON.string(from: jsonObject, key: "Code") ?? "")
        error.text = IQJSON.string(from: jsonObject, key: "Text")
        return error
    }
}
