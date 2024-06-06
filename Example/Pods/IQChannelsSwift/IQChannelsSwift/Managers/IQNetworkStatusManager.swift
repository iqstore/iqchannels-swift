//
//  IQNetworkStatusManager.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 09.05.2024.
//

import Foundation
import SystemConfiguration

class IQNetworkStatusManager {
    
    weak var delegate: IQNetworkStatusManagerDelegate?
    
    private var reachability: SCNetworkReachability
    private var listeners = NSHashTable<AnyObject>.weakObjects()
    
    var isReachable: Bool {
        status != .notReachable
    }
    
    var status: IQNetworkStatus {
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return .notReachable
        }
        return IQNetworkStatus(flags: flags)
    }
    
    init() {
        reachability = SCNetworkReachabilityCreateWithName(nil, "example.com")!
        startNotifier()
    }
    
    deinit {
        stopNotifier()
    }
    
    private func statusChanged() {
        delegate?.networkStatusChanged(status)
    }
    
    private func startNotifier() {
        var context = SCNetworkReachabilityContext(version: 0, info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)
        
        if SCNetworkReachabilitySetCallback(reachability, { (reachability, flags, info) in
            guard let info = info else { return }
            let network = Unmanaged<IQNetworkStatusManager>.fromOpaque(info).takeUnretainedValue()
            DispatchQueue.main.async {
                network.statusChanged()
            }
        }, &context) {
            if SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) {
                // Notifier started successfully
            }
        }
    }
    
    private func stopNotifier() {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }
}
