//
//  IQChannelsConfig.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 08.05.2024.
//

import Foundation

public struct IQChannelsConfig {
    
    public typealias ChatToOpen = (channel: String, chatType: IQChatType)
    
    var address: String
    var channels: [String]
    var chatToOpen: ChatToOpen?
    var styleJson: Data?
    var disableUnreadBadge: Bool = false
    var attachment: IQAttachment? = nil
    var preFillMessages: IQPreFillMessages? = nil
    
    public init(address: String,
                channels: [String],
                chatToOpen: ChatToOpen? = nil,
                styleJson: Data? = nil,
                attachment: IQAttachment? = nil,
                disableUnreadBadge: Bool = false,
                preFillMessages: IQPreFillMessages? = nil) {
        self.address = address
        self.channels = channels
        self.chatToOpen = chatToOpen
        self.styleJson = styleJson
        self.attachment = attachment
        self.disableUnreadBadge = disableUnreadBadge
        self.preFillMessages = preFillMessages
    }

}
