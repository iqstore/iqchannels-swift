import Foundation
import TRVSEventSource

class IQHttpEventSource: NSObject, TRVSEventSourceDelegate {
    
    typealias IQHttpEventSourceCallback = (Any?, Error?) -> Void
    
    private var callback: IQHttpEventSourceCallback?
    private var eventSource: TRVSEventSource?

    init?(url: URL, authToken: String?, customHeaders: [String: String]? = nil, callback: @escaping IQHttpEventSourceCallback) {
        super.init()
        
        self.callback = callback
        
        var additionalHeaders = ["Authorization": "Client \(authToken ?? "")"]
        if let customHeaders = customHeaders {
            additionalHeaders.merge(customHeaders) { (_, new) in new }
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = additionalHeaders
        
        eventSource = TRVSEventSource(url: url, sessionConfiguration: config)
        eventSource?.delegate = self
        eventSource?.open()
    }
    
    func close() {
        eventSource?.close()
    }

    func eventSourceDidOpen(_ eventSource: TRVSEventSource) {
        callback?(nil, nil)
    }
    
    func eventSourceDidClose(_ eventSource: TRVSEventSource) {
        
    }

    func eventSource(_ eventSource: TRVSEventSource, didReceive event: TRVSServerSentEvent) {
        callback?(event.data, nil)
    }

    func eventSource(_ eventSource: TRVSEventSource, didFailWithError error: Error?) {
        var finalError: Error? = error
        if error?.localizedDescription.isEmpty ?? true {
            finalError = NSError.iq_clientError(withLocalizedDescription: NSLocalizedString("Unknown event stream error", comment: ""))
        }
        callback?(nil, finalError)
    }
}
