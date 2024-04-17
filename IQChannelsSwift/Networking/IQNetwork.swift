import Foundation
import SystemConfiguration

enum IQNetworkStatus: Int {
    case notReachable = 0
    case reachableViaWiFi
    case reachableViaWWAN
}

protocol IQNetworkListenerProtocol: AnyObject {
    func networkStatusChanged(_ status: IQNetworkStatus)
}

class IQNetwork {
    private var reachability: SCNetworkReachability
    private var listeners = NSHashTable<AnyObject>.weakObjects()
    
    init() {
        var zeroAddress = sockaddr_in()
        memset(&zeroAddress, 0, MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        var zeroAddressPtr = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                $0
            }
        }

        reachability = SCNetworkReachabilityCreateWithAddress(nil, zeroAddressPtr)!
        startNotifier()
    }
    
    init(listener: IQNetworkListenerProtocol) {
        reachability = SCNetworkReachabilityCreateWithName(nil, "example.com")!
        addListener(listener)
        startNotifier()
    }
    
    deinit {
        stopNotifier()
    }
    
    func isReachable() -> Bool {
        return status() != .notReachable
    }
    
    func status() -> IQNetworkStatus {
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return .notReachable
        }
        return IQNetworkStatus(rawValue: IQNetworkStatusForFlags(flags).rawValue)!
    }
    
    private func statusChanged() {
        let status = self.status()
        for listener in listeners.allObjects {
            (listener as? IQNetworkListenerProtocol)?.networkStatusChanged(status)
        }
    }
    
    func addListener(_ listener: IQNetworkListenerProtocol) {
        listeners.add(listener)
    }
    
    func removeListener(_ listener: IQNetworkListenerProtocol) {
        listeners.remove(listener)
    }
    
    private func startNotifier() {
        var context = SCNetworkReachabilityContext(version: 0, info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)
        
        if SCNetworkReachabilitySetCallback(reachability, { (reachability, flags, info) in
            guard let info = info else { return }
            let network = Unmanaged<IQNetwork>.fromOpaque(info).takeUnretainedValue()
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

private func IQNetworkStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> IQNetworkStatus {
    var returnValue: IQNetworkStatus = .notReachable
    
    if flags.contains(.reachable) {
        returnValue = .reachableViaWiFi
    }
    if flags.contains(.connectionRequired) {
        returnValue = .notReachable
    }
    if flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic) {
        if !flags.contains(.interventionRequired) {
            returnValue = .reachableViaWiFi
        }
    }
    if flags.contains(.isWWAN) {
        returnValue = .reachableViaWWAN
    }
    
    return returnValue
}
