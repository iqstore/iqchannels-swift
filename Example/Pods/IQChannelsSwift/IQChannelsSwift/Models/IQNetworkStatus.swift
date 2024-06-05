//
//  File.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 09.05.2024.
//

import Foundation
import SystemConfiguration

enum IQNetworkStatus: Int {
    case notReachable = 0
    case reachableViaWiFi
    case reachableViaWWAN
    
    init(flags: SCNetworkReachabilityFlags) {
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
        
        self = returnValue
    }

}
