import UIKit
import MessageKit

final class DefaultCellSizeCalculator: MessageSizeCalculator {
    
//    override func sizeForItem(at indexPath: IndexPath) -> CGSize {
//        return .init(width: 300, height: 300)
//    }
}

final class ZeroCellSizeCalculator: MessageSizeCalculator {
    override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        return .zero
    }
}

fileprivate extension UIEdgeInsets {
    init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}

final class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    
    lazy var singleChoicesSizeCalculator = SingleChoicesSizeCalculator(layout: self)
    lazy var cardCellSizeCalculator = CardCellSizeCalculator(layout: self)
    lazy var filePreviewSizeCalculator = FilePreviewSizeCalculator(layout: self)
    lazy var defaultCellSizeCalculator = DefaultCellSizeCalculator(layout: self)
    lazy var textSizeCalculator = IQTextMessageSizeCalculator(layout: self)
    lazy var _typingIndicatorSizeCalculator = IQTypingIndicatorCellSizeCalculator(layout: self)
    lazy var _photoMessageSizeCalculator = IQMediaMessageSizeCalculator(layout: self)
    lazy var zeroSizeCalculator = ZeroCellSizeCalculator(layout: self)
    
    override class var layoutAttributesClass: AnyClass {
        return CustomMessagesCollectionViewLayoutAttributes.self
    }
    
    override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return _typingIndicatorSizeCalculator
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        guard let chatMessage = message as? IQChatMessage else { return defaultCellSizeCalculator }
        
        switch chatMessage.kind {
        case .custom:
            switch chatMessage.payload {
            case .singleChoice:
                return singleChoicesSizeCalculator
            case .card, .carousel:
                return cardCellSizeCalculator
            case .file:
                switch chatMessage.file?.type {
                case .file:
                    return filePreviewSizeCalculator
                default:
                    return zeroSizeCalculator
                }
            default:
                return defaultCellSizeCalculator
            }
        case .text:
            if chatMessage.isDropDown {
                if messagesCollectionView.numberOfItems(inSection: 0) - 1 == indexPath.row,
                   !(chatMessage.singleChoices?.isEmpty ?? true){
                    return singleChoicesSizeCalculator
                }
            }
            return textSizeCalculator
        case .photo:
            return _photoMessageSizeCalculator
        default:
            return super.cellSizeCalculatorForItem(at: indexPath)
        }
    }
    
    override func messageSizeCalculators() -> [MessageSizeCalculator] {
        var messageSizeCalculators: [MessageSizeCalculator] = super.messageSizeCalculators()
        messageSizeCalculators.append(contentsOf: [
            singleChoicesSizeCalculator,
            cardCellSizeCalculator,
            filePreviewSizeCalculator,
            defaultCellSizeCalculator,
            textSizeCalculator,
            _photoMessageSizeCalculator
        ])
        return messageSizeCalculators
    }
}

final class CustomMessagesCollectionViewLayoutAttributes: MessagesCollectionViewLayoutAttributes {
    
    public var additionalContainerSize: CGSize = .zero
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! CustomMessagesCollectionViewLayoutAttributes
        copy.additionalContainerSize = additionalContainerSize
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? CustomMessagesCollectionViewLayoutAttributes {
            return super.isEqual(object) && attributes.additionalContainerSize == additionalContainerSize
        } else {
            return false
        }
    }
}
