import Foundation

class IQClientAuth {
    
    var client: IQClient?
    var session: IQClientSession?
}

extension IQClientAuth {
    
    static func fromJSONObject(_ object: Any?) -> IQClientAuth? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }

        let auth = IQClientAuth()
        auth.client = IQClient.fromJSONObject(IQJSON.dict(from: jsonObject, key: "Client"))
        auth.session = IQClientSession.fromJSONObject(IQJSON.dict(from: jsonObject, key: "Session"))
        return auth
    }
}
