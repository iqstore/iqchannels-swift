//
//  IQLog.swift
//  IQChannelsSwift
//
//  Created by Mikhail Zinkov on 02.11.2024.
//

import SwiftUI
import OSLog

class IQLog {
    private static var isLoggingEnabled = true

    static func configure(state: Bool) {
        isLoggingEnabled = state
    }
    
    // 
    static func debug(message: String) {
        if isLoggingEnabled {
            os_log("%{public}s", type: .debug, "[DEBUG]: \(message)")
        }
    }

    static func error(message: String) {
        if isLoggingEnabled {
            os_log("%{public}s", type: .error, "[ERROR]: \(message)")
        }
    }
}
