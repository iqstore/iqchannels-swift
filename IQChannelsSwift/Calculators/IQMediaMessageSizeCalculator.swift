//
//  File.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 26.04.2024.
//

import UIKit
import MessageKit

class IQMediaMessageSizeCalculator: MediaMessageSizeCalculator {
    
    override func messageContainerSize(for message: any MessageType) -> CGSize {
        var size = super.messageContainerSize(for: message)
        if let message = message as? IQChatMessage,
           message.replyToMessage != nil {
            size.height += 49
        }
        return size
    }

}
