import Foundation

class IQClientSession {
    
    var id: Int?
    var clientId: Int?
    var token: String?
    var integration: Bool?
    var integrationHash: String?
    var integrationCredentials: String?
    var createdAt: Int?
}

extension IQClientSession {
    
    static func fromJSONObject(_ object: Any?) -> IQClientSession? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }

        var session = IQClientSession()
        session.id = IQJSON.int(from: jsonObject, key: "Id")
        session.clientId = IQJSON.int(from: jsonObject, key: "ClientId")
        session.token = IQJSON.string(from: jsonObject, key: "Token")
        session.integration = IQJSON.bool(from: jsonObject, key: "Integration")
        session.integrationHash = IQJSON.string(from: jsonObject, key: "IntegrationHash")
        session.integrationCredentials = IQJSON.string(from: jsonObject, key: "IntegrationCredentials")
        session.createdAt = IQJSON.int(from: jsonObject, key: "CreatedAt")
        
        return session
    }
}
