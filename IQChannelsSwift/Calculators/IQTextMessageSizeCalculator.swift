//
//  IQTextMessageSizeCalculator.swift
//  IQChannelsSwift
//
//  Created by Daulet on 07.04.2024.
//

import MessageKit

class IQTextMessageSizeCalculator: TextMessageSizeCalculator {
    
    override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init(layout: layout)
        
        incomingMessageLabelInsets.bottom = 28
        outgoingMessageLabelInsets.bottom = 28
    }
    
    override func messageContainerSize(for message: any MessageType) -> CGSize {
        guard let message = message as? IQChatMessage else { return super.messageContainerSize(for: message) }
        var size = super.messageContainerSize(for: message)
        size.width = max(size.width, (message.read || message.received) ? 79 : 59)
        if message.isPendingRatingMessage{
            size.height += 86
        }
        return size
    }

}
