//
//  IQChannelsConfig.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 08.05.2024.
//

import Foundation

public struct IQChannelsConfig {
    
    var address: String
    var channels: [String]
    var styleJson: Data?
    var disableUnreadBadge: Bool = false
    
    public init(address: String, channels: [String], styleJson: Data? = nil, disableUnreadBadge: Bool = false) {
        self.address = address
        self.channels = channels
        self.styleJson = styleJson
        self.disableUnreadBadge = disableUnreadBadge
    }

}
