import Foundation

class IQFileToken {
    var token: String?
}

extension IQFileToken {
    
    static func fromJSONObject(_ object: Any?) -> IQFileToken? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }
        
        let fileToken = IQFileToken()
        fileToken.token = IQJSON.string(from: jsonObject, key: "token")
        return fileToken
    }
}
