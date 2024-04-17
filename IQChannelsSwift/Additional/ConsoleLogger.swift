import Foundation

class ConsoleLogger {
    
    var separatorLine: String
    
    init() {
        separatorLine = "".padding(toLength: 64, withPad: "☰", startingAt: 0)
    }
    
    func title(_ token: String) -> String {
        return "[ NetworkS: HTTP \(token) ]"
    }
    
    func getLog(for request: URLRequest?) -> String {
        var log = ""
        
        if let url = request?.url, let method = request?.httpMethod {
            var urlString = url.absoluteString
            if urlString.hasSuffix("?") {
                urlString = String(urlString.prefix(urlString.count - 1))
            }
            log += "‣ URL: \(urlString)\n\n"
            log += "‣ METHOD: \(method)\n\n"
        }
        
        if let headerFields = request?.allHTTPHeaderFields, headerFields.count > 0 {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: headerFields, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    log += "‣ REQUEST HEADERS: \(jsonString)\n\n"
                }
            } catch {
                // Handle error
            }
        }
        
        if let httpBody = request?.httpBody, httpBody.count > 0 {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: httpBody, options: [])
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    log += "‣ REQUEST BODY: \(jsonString)\n\n"
                } else {
                    log += "‣ REQUEST BODY (FAILED TO PRINT)\n\n"
                }
            } catch {
                // Handle error
            }
        }
        
        return log
    }
    
    func logRequest(_ request: URLRequest?) {
        var log = ""
        
        log += "\n\(separatorLine)\n\n"
        log += "\(title("Request ➡️"))\n\n"
        log += "‣ TIME: \(Date())\n\n"
        log += getLog(for: request)
        log += "\(separatorLine)\n\n"
        
        print(log)
    }
    
    func logRequest(_ request: URLRequest?,
                    response: HTTPURLResponse?,
                    responseData: Data?,
                    error: Error?,
                    responseIsCached: Bool,
                    responseIsMocked: Bool) {
        var log = ""
        
        log += "\n\(separatorLine)\n\n"
        
        let titlePrefix = responseIsCached ? "Cached " : (responseIsMocked ? "Mocked " : "")
        log += "\(title("\(titlePrefix)Response ⬅️"))\n\n"
        log += "‣ TIME: \(Date())\n\n"
        
        if let statusCode = response?.statusCode, statusCode != 0 {
            let statusEmoji = (statusCode >= 200 && statusCode < 300) ? "✅" : "⚠️"
            log += "‣ STATUS CODE: \(statusCode) \(statusEmoji)\n\n"
        }
        log += getLog(for: request)
        
        if let headerFields = response?.allHeaderFields, headerFields.count > 0 {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: headerFields, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    log += "‣ RESPONSE HEADERS: \(jsonString)\n\n"
                }
            } catch {
                // Handle error
            }
        }
        
        if let responseData = responseData, responseData.count > 0 {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: [])
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    log += "‣ RESPONSE BODY: \(jsonString)\n\n"
                } else {
                    log += "‣ RESPONSE BODY (FAILED TO PRINT)\n\n"
                }
            } catch {
                // Handle error
            }
        }
        
        if let error = error {
            log += "‣ ERROR: \(error.localizedDescription)\n\n"
        }
        
        log += "\(separatorLine)\n\n"
        
        print(log)
    }
}
