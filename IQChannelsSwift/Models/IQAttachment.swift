//
//  IQAttachment.swift
//  Pods
//
//  Created by Muhammed Aralbek on 29.07.2024.
//  
//

import Foundation

public struct IQAttachment {
    public var channel: String
    public var chatType: IQChatType
    public var attachments: [IQAttachmentItem]
    
    public init(channel: String, chatType: IQChatType, attachments: [IQAttachmentItem]) {
        self.channel = channel
        self.chatType = chatType
        self.attachments = attachments
    }
}

public enum IQAttachmentItem {
    case text(String)
    case file(data: Data, filename: String)
}
