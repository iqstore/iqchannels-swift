import Foundation

class IQResponse {
    
    var ok: Bool
    var error: IQError?
    var result: Any?
    var rels: IQRelations?
    
    init(ok: Bool = false, error: IQError? = nil, result: Any? = nil, rels: IQRelations? = nil) {
        self.ok = ok
        self.error = error
        self.result = result
        self.rels = rels
    }
}

extension IQResponse {
    
    static func fromJSONObject(_ object: Any?) -> IQResponse? {
        guard let jsonObject = object as? [String: Any] else {
            return nil
        }

        let response = IQResponse()
        response.ok = IQJSON.bool(from: jsonObject, key: "OK")
        response.error = IQError.fromJSONObject(IQJSON.dict(from: jsonObject, key: "Error"))
        response.result = jsonObject["Result"]
        response.rels = IQRelations.fromJSONObject(IQJSON.dict(from: jsonObject, key: "Rels"))
        return response
    }

    static func fromJSONData(_ data: Data) throws -> IQResponse {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let jsonDict = jsonObject as? [String: Any] else {
            throw NSError.iq_clientError()
        }
        
        guard let response = self.fromJSONObject(jsonDict) else {
            throw NSError.iq_clientError()
        }
        
        return response
    }
}
