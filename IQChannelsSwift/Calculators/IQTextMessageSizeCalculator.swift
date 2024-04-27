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
    
    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        attributes.messageLabelInsets = messageLabelInsets(for: message)
    }
    
    private func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        var inset = isFromCurrentSender ? outgoingMessageLabelInsets : incomingMessageLabelInsets
        if let message = message as? IQChatMessage,
           message.replyToMessage != nil {
            inset.top += 42
        }
        return inset
    }
    
    override func messageContainerSize(for message: any MessageType) -> CGSize {
        guard let message = message as? IQChatMessage else { return super.messageContainerSize(for: message) }
        var size = super.messageContainerSize(for: message)
        size.width = max(size.width, 79)
        if message.isPendingRatingMessage{
            size.height += 86
        }
        if message.replyToMessage != nil {
            size.height += 42
            size.width = messageContainerMaxWidth(for: message)
        }
        return size
    }

}
