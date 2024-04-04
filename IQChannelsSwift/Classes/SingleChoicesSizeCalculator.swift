import UIKit
import MessageKit

final class SingleChoicesSizeCalculator: MessageSizeCalculator {
    
    var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)
    
    var incomingMessageLabelInsets = UIEdgeInsets(top: 7, left: 18, bottom: 7, right: 14)
    var outgoingMessageLabelInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 18)

    override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        
        guard let attributes = attributes as? CustomMessagesCollectionViewLayoutAttributes else { return }

        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)

        attributes.additionalContainerSize = additionalContainerSize(for: message)
        attributes.messageLabelInsets = messageLabelInsets(for: message)
        attributes.messageLabelFont = messageLabelFont
    }

    override func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        let maxWidth = super.messageContainerMaxWidth(for: message)
        let textInsets = messageLabelInsets(for: message)
        return maxWidth - (textInsets.left + textInsets.right)
    }

    override func messageContainerSize(for message: MessageType) -> CGSize {
        guard let chatMessage = message as? IQChatMessage else { return .zero }
        let maxWidth = messageContainerMaxWidth(for: message)

        var messageContainerSize: CGSize
        let attributedText: NSAttributedString = NSAttributedString(string: chatMessage.text, attributes: [.font: messageLabelFont])

        messageContainerSize = labelSize(for: attributedText, considering: maxWidth)

        let messageInsets = messageLabelInsets(for: message)
        messageContainerSize.width += (messageInsets.left + messageInsets.left)
        messageContainerSize.height += (messageInsets.top + messageInsets.bottom)

        return messageContainerSize
    }

    override func cellContentHeight(for message: MessageType, at indexPath: IndexPath) -> CGFloat {
        let contentHeight = super.cellContentHeight(for: message, at: indexPath)
        let additionalContainerHeight = additionalContainerSize(for: message).height
        return contentHeight + additionalContainerHeight
    }
    
    internal func additionalContainerSize(for message: MessageType) -> CGSize {
        guard let chatMessage = message as? IQChatMessage else { return .zero }
        
        if chatMessage.isDropDown {
            let maxWidth = messagesLayout.itemWidth - avatarSize(for: message).width
            let choices = chatMessage.singleChoices ?? []
            let height: CGFloat = 32
            var index = 0
            var choiceIndex = 0

            repeat {
                var lineWidth: CGFloat = 0

                while lineWidth <= maxWidth && choiceIndex < choices.count {
                    let title = choices[choiceIndex].title ?? ""
                    let boundingRect = title.boundingRect(with: CGSize(width: -1, height: -1),
                                                          options: .usesLineFragmentOrigin,
                                                          attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)],
                                                          context: nil)
                    let choiceWidth = 6 + boundingRect.size.width + 6 + 1
                    lineWidth += choiceWidth
                    choiceIndex += 1
                }

                if lineWidth > maxWidth {
                    choiceIndex -= 1
                }

                index += 1
            } while choiceIndex < choices.count
            
            return CGSize(width: maxWidth,
                          height: height * CGFloat(index) + 4 * CGFloat(index - 1))
        } else {
            return .init(width: messageContainerSize(for: message).width,
                         height: CGFloat((chatMessage.singleChoices?.count ?? 0) * 35) - 3)
        }
    }
    
    internal func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageLabelInsets : incomingMessageLabelInsets
    }
    
    internal func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return rect.size
    }
}
