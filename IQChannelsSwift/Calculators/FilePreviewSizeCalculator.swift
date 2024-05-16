import UIKit
import MessageKit

final class FilePreviewSizeCalculator: MessageSizeCalculator {
    
    var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)
    
    var incomingCellInsets = UIEdgeInsets(top: 8, left: 12, bottom: 28, right: 12)
    var outgoingCellInsets = UIEdgeInsets(top: 8, left: 12, bottom: 28, right: 12)
    
    override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        
        guard let attributes = attributes as? CustomMessagesCollectionViewLayoutAttributes else { return }
        
        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        
        var inset = cellInsets(for: message)
        if let message = message as? IQChatMessage,
           message.replyToMessage != nil {
            inset.top += 42
        }
        attributes.messageLabelInsets = inset
        attributes.messageLabelFont = messageLabelFont
    }

    override func messageContainerSize(for message: MessageType) -> CGSize {
        guard let chatMessage = message as? IQChatMessage else { return .zero }
        
        let maxWidth = messageContainerMaxWidth(for: message)
        let attributedText = NSMutableAttributedString()
        attributedText.append(.init(string: chatMessage.text + "\n", attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]))
        attributedText.append(.init(string: IQFileSize.unit(with: chatMessage.file?.size ?? 0), attributes: [
            .font: UIFont.systemFont(ofSize: 15)
        ]))
        let labelSize = labelSize(for: attributedText, considering: maxWidth - 32 - 8 - 24)
        var height = max(labelSize.height, 18) + (cellInsets(for: message).top + cellInsets(for: message).bottom)
        if chatMessage.replyToMessage != nil {
            height += 49
        }
        return CGSize(width: maxWidth,
                      height: height)
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
