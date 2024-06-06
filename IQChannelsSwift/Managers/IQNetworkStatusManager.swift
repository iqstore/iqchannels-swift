//
//  IQNetworkStatusManager.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 09.05.2024.
//

import Foundation
import Network

class IQNetworkStatusManager {
    
    weak var delegate: IQNetworkStatusManagerDelegate?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .userInteractive)
    
    var isReachable: Bool {
        status != .notReachable
    }
    
    var status: IQNetworkStatus = .notReachable
    
    init() {
        startMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let status: IQNetworkStatus = path.status == .satisfied ? .reachable : .notReachable
            if self?.status != status {
                self?.status = status
                    self?.delegate?.networkStatusChanged(status)
            } else {
                self?.status = status
            }
        }
        monitor.start(queue: queue)
    }
    
}
