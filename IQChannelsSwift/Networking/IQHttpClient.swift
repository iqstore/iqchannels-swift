import Foundation

// Typealias for callback blocks
typealias IQHttpClientAutCallback = (IQClientAuth?, Error?) -> Void
typealias IQHttpClientSignupCallback = (IQClientAuth?, Error?) -> Void
typealias IQHttpChatCallback = (IQChat?, Error?) -> Void
typealias IQHttpMessagesCallback = ([IQChatMessage]?, Error?) -> Void
typealias IQHttpEventsCallback = ([IQChatEvent]?, Error?) -> Void
typealias IQHttpUnreadCallback = (NSNumber?, Error?) -> Void
typealias IQHttpFileCallback = (IQFile?, Error?) -> Void
typealias IQHttpFileTokenCallback = (IQFileToken?, Error?) -> Void
typealias IQHttpVoidCallback = (Error?) -> Void

// Class for handling HTTP requests
class IQHttpClient {
    
    var address: String?
    var token: String?
    private var log: IQLog?
    private var session: URLSession
    private var relations: IQRelationService?
    private var customHeaders: [String: String]?
    private let logger = ConsoleLogger()

    init(log: IQLog?, relations: IQRelationService?, address: String) {
        self.log = log
        self.address = address
        self.session = URLSession(configuration: .ephemeral)
        self.relations = relations
    }

    func setCustomHeaders(_ headers: [String: String]) {
        self.customHeaders = headers
    }

    func clientsSignup(channel: String?, callback: @escaping IQHttpClientSignupCallback) -> IQHttpRequest {
        let path = "/clients/signup"
        let input = IQClientInput(channel: channel)
        return post(path, jsonEncodable: input) { result, error in
            if let error = error {
                callback(nil, error)
                return
            }
            guard let auth = IQClientAuth.fromJSONObject(result?.value) else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse client authentication"])
                callback(nil, error)
                return
            }
            self.relations?.clientAuth(auth, with: result?.relations)
            callback(auth, nil)
        }
    }

    func clientsAuth(token: String, callback: @escaping IQHttpClientAutCallback) -> IQHttpRequest {
        let path = "/clients/auth"
        let req = IQClientAuthRequest(token: token)
        return post(path, jsonEncodable: req) { result, error in
            if let error = error {
                callback(nil, error)
                return
            }
            guard let auth = IQClientAuth.fromJSONObject(result?.value) else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse client authentication"])
                callback(nil, error)
                return
            }
            self.relations?.clientAuth(auth, with: result?.relations)
            callback(auth, nil)
        }
    }

    func clientsIntegrationAuth(credentials: String, channel: String?, callback: @escaping (IQClientAuth?, Error?) -> Void) -> IQHttpRequest {
        let path = "/clients/integration_auth"
        let req = IQClientIntegrationAuthRequest()
        req.credentials = credentials
        req.channel = channel

        return self.post(path, jsonEncodable: req) { result, error in
            if let error = error {
                callback(nil, error)
                return
            }

            guard let auth = IQClientAuth.fromJSONObject(result?.value) else {
                // Handle error condition where IQClientAuth cannot be created from JSON object
                return
            }

            self.relations?.clientAuth(auth, with: result?.relations)
            callback(auth, nil)
        }
    }

    func chatsChannel(channel: String, callback: @escaping IQHttpChatCallback) -> IQHttpRequest {
        let path = "/chats/channel/chat/\(channel)"
        return self.post(path, jsonEncodable: nil) { result, error in
            if let error = error {
                callback(nil, error)
                return
            }

            guard let chat = IQChat.fromJSONObject(result?.value) else {
                // Handle error condition where IQChat cannot be created from JSON object
                return
            }

            self.relations?.chat(chat, with: result?.relations)
            callback(chat, nil)
        }
    }

    func chatsChannel(channel: String?, query: IQMaxIdQuery, callback: @escaping IQHttpMessagesCallback) -> IQHttpRequest {
        let path = "/chats/channel/messages/\(channel ?? "")"
        return self.post(path, jsonEncodable: query) { result, error in
            if let error = error {
                callback(nil, error)
                return
            }

            let messages = IQChatMessage.fromJSONArray(result?.value)
            self.relations?.chatMessages(messages, with: result?.relations)
            callback(messages, nil)
        }
    }

    func chatsChannel(channel: String?, typing: @escaping IQHttpVoidCallback) -> IQHttpRequest {
        let path = "/chats/channel/typing/\(channel ?? "")"
        return self.post(path, jsonEncodable: nil) { result, error in
            typing(error)
        }
    }

    func chatsChannel(channel: String?, form: IQChatMessageForm, callback: @escaping IQHttpVoidCallback) -> IQHttpRequest {
        let path = "/chats/channel/send/\(channel ?? "")"
        return self.post(path, jsonEncodable: form) { result, error in
            callback(error)
        }
    }

    func chatsChannel(channel: String?, query: IQChatEventQuery, callback: @escaping IQHttpEventsCallback) -> IQHttpRequest {
        var path = "/sse/chats/channel/events/\(channel ?? "")"
        if let lastEventId = query.lastEventId {
            path += "?LastEventId=\(lastEventId)"
        }
        if let limit = query.limit {
            if path.contains("?") {
                path += "&"
            } else {
                path += "?"
            }
            path += "Limit=\(limit)"
        }

        return self.sse(path: path) { result, error in
            if let error = error {
                callback(nil, error)
                return
            }
            if result == nil {
                // An opened event.
                callback([], nil)
                return
            }

            let events = IQChatEvent.fromJSONArray(result?.value)
            self.relations?.chatEvents(events, with: result?.relations)
            callback(events, nil)
        }
    }

    func chatsChannel(channel: String?, callback: @escaping IQHttpUnreadCallback) -> IQHttpRequest {
        let path = "/sse/chats/channel/unread/\(channel ?? "")"
        return self.sse(path: path) { result, error in
            if let error = error {
                callback(nil, error)
                return
            }
            if result == nil {
                // An opened event.
                return
            }

            var unread: NSNumber = 0
            if let value = result?.value as? NSNumber {
                unread = value
            }
            callback(unread, nil)
        }
    }
    
    func chatsMessagesReceived(_ messageIds: [Int]?, callback: @escaping IQHttpVoidCallback) -> IQHttpRequest? {
        let path = "/chats/messages/received"
        return post(path, json: messageIds, callback: { response, error in
            callback(error)
        })
    }

    func chatsMessagesRead(_ messageIds: [Int]?, callback: @escaping IQHttpVoidCallback) -> IQHttpRequest? {
        let path = "/chats/messages/read"
        return post(path, json: messageIds, callback: { response, error in
            callback(error)
        })
    }

    func filesUploadImage(_ filename: String?, data: Data?, callback: @escaping IQHttpFileCallback) -> IQHttpRequest? {
        let path = "/files/upload"
        let params = [
            "Type": "image"
        ]
        let files = [
            "File": IQHttpFile(name: filename, data: data, mimeType: "")
        ]

        return post(path, multipart: params, files: files, callback: { result, error in
            if let error {
                callback(nil, error)
                return
            }

            let file0 = IQFile.fromJSONObject(result?.value)
            self.relations?.file(file0, with: result?.relations)
            callback(file0, nil)
        })
    }

    func filesUploadData(_ filename: String?, data: Data?, callback: @escaping IQHttpFileCallback) -> IQHttpRequest? {
        let path = "/files/upload"
        let params = [
            "Type": "file"
        ]
        let files = [
            "File": IQHttpFile(name: filename, data: data, mimeType: "")
        ]

        return post(path, multipart: params, files: files, callback: { result, error in
            if let error {
                callback(nil, error)
                return
            }

            let file0 = IQFile.fromJSONObject(result?.value)
            self.relations?.file(file0, with: result?.relations)
            callback(file0, nil)
        })
    }
    
    func filesToken(_ fileId: String, callback: @escaping (IQFileToken?, Error?) -> Void) -> IQHttpRequest {
        let path = "/files/token"
        let params: [String: Any] = ["FileId": fileId]
        
        return post(path, json: params) { result, error in
            if let error = error {
                callback(nil, error)
                return
            }
            
            if let token = IQFileToken.fromJSONObject(result?.value) {
                callback(token, nil)
            } else {
                // Handle invalid JSON object
                let error = NSError(domain: "YourDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON object"])
                callback(nil, error)
            }
        }
    }

    func fileURL(_ fileId: String, token: String) -> URL? {
        let path = "/files/get/\(fileId)?token=\(token)"
        return requestUrl(path)
    }

    func ratingsRate(_ ratingId: Int, value: Int, callback: @escaping (Error?) -> Void) -> IQHttpRequest {
        let path = "/ratings/rate"
        let params: [String: Any] = ["RatingId": ratingId, "Rating": ["Value": value]]
        
        return post(path, json: params) { result, error in
            callback(error)
        }
    }

    func ratingsIgnore(_ ratingId: Int64, callback: @escaping (Error?) -> Void) -> IQHttpRequest {
        let path = "/ratings/ignore"
        let params: [String: Any] = ["RatingId": ratingId]
        
        return post(path, json: params) { result, error in
            callback(error)
        }
    }

    func pushChannel(_ channel: String?, apnsToken token: String, callback: @escaping (Error?) -> Void) -> IQHttpRequest {
        let path = "/push/channel/apns/\(channel ?? "")"
        let params: [String: Any] = ["Token": token]
        
        return post(path, json: params) { result, error in
            callback(error)
        }
    }
    
    func post(_ path: String,
              jsonEncodable body: IQJSONEncodable?,
              callback: @escaping (IQResult?, Error?) -> Void) -> IQHttpRequest {
        let json: Any?
        if let body = body {
            json = body.toJSONObject()
        } else {
            json = nil
        }
        
        return post(path, json: json, callback: callback)
    }

    func post(_ path: String,
              json jsonObject: Any?,
              callback: @escaping (IQResult?, Error?) -> Void) -> IQHttpRequest {
        var error: NSError?
        let request = self.request(path, json: jsonObject, error: &error)
        if let error = error {
            callback(nil, error)
            return IQHttpRequest()
        }
        
        return post(request: request, callback: callback)
    }

    func post(_ path: String,
              multipart params: [String: String],
              files: [String: IQHttpFile],
              callback: @escaping (IQResult?, Error?) -> Void) -> IQHttpRequest {
        var error: NSError?
        let request = self.request(path, multipart: params, files: files, error: &error)
        if let error = error {
            callback(nil, error)
            return IQHttpRequest()
        }
        
        return post(request: request, callback: callback)
    }

    func post(request: URLRequest?,
              callback: @escaping (IQResult?, Error?) -> Void) -> IQHttpRequest {
        guard let request else { return IQHttpRequest() }
        
        let task = session.dataTask(with: request) { data, response, taskError in
            #if DEBUG
            self.logger.logRequest(request,
                                   response: response as? HTTPURLResponse,
                                   responseData: data,
                                   error: taskError,
                                   responseIsCached: false,
                                   responseIsMocked: false)
            #endif
            self.handleResponse(url: request.url,
                                data: data,
                                response: response,
                                error: taskError,
                                callback: callback)
        }
        #if DEBUG
        logger.logRequest(request)
        #endif
        task.resume()
        return IQHttpRequest {
            task.cancel()
        }
    }
    
    func requestUrl(_ path: String) -> URL {
        let address = address ?? ""
        var formattedAddress = address.hasSuffix("/") ? String(address.dropLast()) : address
        formattedAddress += "/public/api/v1\(path)"
        return URL(string: formattedAddress)!
    }

    func request(_ path: String, json: Any?, error: inout NSError?) -> URLRequest? {
        let url = requestUrl(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("TOKEN EXISTS: \(token != nil)")
        if let token {
            let auth = "Client \(token)"
            request.addValue(auth, forHTTPHeaderField: "Authorization")
        }
        
        if let customHeaders {
            for (key, value) in customHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        guard let json = json else { return request }
        
        do {
            let body = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            request.httpBody = body
            request.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        } catch let serializationError as NSError {
            error = serializationError
            return nil
        }
        
        return request
    }

    func request(_ path: String, multipart params: [String: Any], files: [String: IQHttpFile], error: inout NSError?) -> URLRequest? {
        let url = requestUrl(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = requestMultipartBoundary()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        if let customHeaders {
            for (key, value) in customHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let body = requestMultipartBody(params: params, files: files, boundary: boundary)
        request.httpBody = body
        request.addValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        
        return request
    }

    func requestMultipartBoundary() -> String {
        return "-----------iqchannels-boundary-\(UUID().uuidString)"
    }

    func requestMultipartBody(params: [String: Any], files: [String: IQHttpFile], boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in params {
            guard let valueString = value as? String else { continue }
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(valueString)\r\n".data(using: .utf8)!)
        }
        
        for (key, file) in files {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(file.name ?? "")\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(file.mimeType ?? "")\r\n\r\n".data(using: .utf8)!)
            if let data = file.data {
                body.append(data)
            }
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    func handleResponse(url: URL?, data: Data?, response: URLResponse?, error: Error?, callback: @escaping (IQResult?, Error?) -> Void) {
        if let error = error {
            log?.debug("POST ERROR \(url?.absoluteString ?? "") error=\(error.localizedDescription)")
            callback(nil, error)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            let text = HTTPURLResponse.localizedString(forStatusCode: 500)
            let error = NSError.iq_clientError(withLocalizedDescription: text)
            callback(nil, error)
            return
        }
        
        log?.debug("POST \(httpResponse.statusCode) \(url?.absoluteString ?? "")")
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            let text = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            let error = NSError.iq_clientError(withLocalizedDescription: text)
            callback(nil, error)
            return
        }
        
        guard let data = data, !data.isEmpty else {
            let result = IQResult()
            callback(result, nil)
            return
        }
        
        do {
            let response = try IQResponse.fromJSONData(data)
            if !response.ok {
                let error = NSError.iq_withIQError(response.error)
                callback(nil, error)
                return
            }
            
            let result = IQResult(value: response.result, relations: relations?.mapFromRelations(response.rels))
            callback(result, nil)
        } catch {
            log?.debug("POST JSON ERROR \(url?.absoluteString ?? "") error=\(error.localizedDescription)")
            callback(nil, error)
        }
    }
    
    func sse(path: String, callback: @escaping (IQResult?, Error?) -> Void) -> IQHttpRequest {
        let url = requestUrl(path)
        log?.debug("SSE \(url.absoluteString)")
        
        let eventSource = IQHttpEventSource(url: url, authToken: token, customHeaders: customHeaders) { data, error in
            guard error == nil else {
                callback(nil, error)
                return
            }
            
            guard let data = data as? Data else {
                callback(nil, nil)
                return
            }
            
            do {
                let response = try IQResponse.fromJSONData(data)
                if !response.ok {
                    let error = NSError.iq_withIQError(response.error)
                    callback(nil, error)
                    return
                }
                
                let result = IQResult(value: response.result, relations: self.relations?.mapFromRelations(response.rels))
                callback(result, nil)
            } catch {
                self.log?.debug("SSE JSON ERROR \(url.absoluteString) error=\(error.localizedDescription)")
                callback(nil, error)
            }
        }
        
        return IQHttpRequest {
            eventSource?.close()
        }
    }
}
