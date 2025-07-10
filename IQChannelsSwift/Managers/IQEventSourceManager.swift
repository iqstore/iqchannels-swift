//
//  IQEventSourceManager.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 13.05.2024.
//

import UIKit
#if canImport(IQChannelsObjC)
import IQChannelsObjC
#endif

class IQEventSourceManager: NSObject, TRVSEventSourceDelegate {
    
    typealias Callback = (Data?, Error?) -> Void
    
    private var callback: Callback?
    private var onOpen: (() -> Void)
    private(set) var eventSource: TRVSEventSource?

    init(url: URL, authToken: String?, customHeaders: [String: String]? = nil, onOpen: @escaping (() -> Void), callback: @escaping Callback) {
        self.callback = callback
        self.onOpen = onOpen
        super.init()
        
//        var additionalHeaders = ["Cookie": "client-session=\(authToken)"]
//        var additionalHeaders = ["Cookie": "x-client-token=\(authToken)"]
        var additionalHeaders = ["Authorization": "Client \(authToken ?? "")"]
        
        if let customHeaders = customHeaders {
            additionalHeaders.merge(customHeaders) { (_, new) in new }
        }
        
//        print("SSE URL: \(url.absoluteString)")
//        print("SSE Headers:")
//        for (key, value) in additionalHeaders {
//            print("  \(key): \(value)")
//        }
        
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = additionalHeaders
        
        eventSource = TRVSEventSource(url: url, sessionConfiguration: config)
        eventSource?.delegate = self
        eventSource?.open()
    }
    
    deinit {
        eventSource?.close()
    }
    
    func close() {
        eventSource?.close()
    }

    func eventSourceDidOpen(_ eventSource: TRVSEventSource) {
        onOpen()
    }
    
    func eventSourceDidClose(_ eventSource: TRVSEventSource) {
        
    }

    func eventSource(_ eventSource: TRVSEventSource, didReceive event: TRVSServerSentEvent) {
        callback?(event.data, nil)
    }

    func eventSource(_ eventSource: TRVSEventSource, didFailWithError error: Error?) {
        var finalError: Error? = error
        if error?.localizedDescription.isEmpty ?? true {
            finalError = NSError.clientError("Unknown event stream error")
        }
        print("\(error)")
        callback?(nil, finalError)
    }
}
