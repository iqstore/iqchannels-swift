import UIKit
import MessageKit

final class CardCellSizeCalculator: MessageSizeCalculator {
    
    var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)
    
    var incomingCellInsets = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 16)
    var outgoingCellInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 18)
    
    override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        
        guard let attributes = attributes as? CustomMessagesCollectionViewLayoutAttributes else { return }
        
        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        
        attributes.messageLabelInsets = cellInsets(for: message)
        attributes.messageLabelFont = messageLabelFont
    }

    override func messageContainerSize(for message: MessageType) -> CGSize {
        guard let chatMessage = message as? IQChatMessage else { return .zero }
        
        let maxWidth = messageContainerMaxWidth(for: message)
        let attributedText: NSAttributedString = NSAttributedString(string: chatMessage.text,
                                                                    attributes: [.font: messageLabelFont])
        let labelSize = labelSize(for: attributedText, considering: maxWidth)
        let imageHeight: CGFloat = chatMessage.isMediaMessage ? 150 : 0
        
        return CGSize(width: min(maxWidth, 250),
                      height: imageHeight + labelSize.height + CGFloat((chatMessage.actions?.count ?? 0) * 32) + (cellInsets(for: message).top + cellInsets(for: message).bottom))
    }
    
    internal func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return rect.size
    }
    
    internal func cellInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingCellInsets : incomingCellInsets
    }
}
