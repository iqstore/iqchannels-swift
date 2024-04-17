import UIKit
import MessageKit
import SnapKit

final class IQSingleChoicesCell: UICollectionViewCell {

    // MARK: - PROPERTIES
    private var avatarView = AvatarView()

    private var messageContainerView: MessageContainerView = {
        let containerView = MessageContainerView()
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    private var messageLabel = MessageLabel()
    
    private var singleChoicesView: IQSingleChoicesView = .init()

    private var cellTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private var cellBottomLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private var messageTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        return label
    }()

    private var messageBottomLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        return label
    }()

    private var accessoryView: UIView = UIView()

    weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }
    
    var singleChoiceDelegate: IQSingleChoicesViewDelegate? {
        get {
            singleChoicesView.delegate
        } set {
            singleChoicesView.delegate = newValue
        }
    }

    // MARK: - INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }

    // MARK: - SETUP
    private func setupSubviews() {
        contentView.addSubview(accessoryView)
        contentView.addSubview(cellTopLabel)
        contentView.addSubview(messageTopLabel)
        contentView.addSubview(messageBottomLabel)
        contentView.addSubview(cellBottomLabel)
        contentView.addSubview(messageContainerView)
        contentView.addSubview(avatarView)
        contentView.addSubview(singleChoicesView)
        messageContainerView.addSubview(messageLabel)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellTopLabel.text = nil
        cellBottomLabel.text = nil
        messageTopLabel.text = nil
        messageBottomLabel.text = nil
        messageLabel.attributedText = nil
        messageLabel.text = nil
        singleChoicesView.clearSingleChoices()
        singleChoiceDelegate = nil
    }

    // MARK: - CONFIGURATION
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? CustomMessagesCollectionViewLayoutAttributes else { return }
        
        layoutMessageContainerView(with: attributes)
        setupMessageLabel(with: attributes)
        layoutMessageBottomLabel(with: attributes)
        layoutCellBottomLabel(with: attributes)
        layoutCellTopLabel(with: attributes)
        layoutMessageTopLabel(with: attributes)
        layoutAvatarView(with: attributes)
        layoutAccessoryView(with: attributes)
        layoutSingleChoicesView(with: attributes)
    }

    func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError("MessagesDataSource has not been set.")
        }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError("MessagesDisplayDelegate has not been set.")
        }
        guard let chatMessage = message as? IQChatMessage else { return }

        delegate = messagesCollectionView.messageCellDelegate

        let messageColor = displayDelegate.backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
        let messageStyle = displayDelegate.messageStyle(for: message, at: indexPath, in: messagesCollectionView)

        displayDelegate.configureAvatarView(avatarView, for: message, at: indexPath, in: messagesCollectionView)

        displayDelegate.configureAccessoryView(accessoryView, for: message, at: indexPath, in: messagesCollectionView)
        
        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)

        messageLabel.configure {
            messageLabel.enabledDetectors = enabledDetectors
            for detector in enabledDetectors {
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                messageLabel.setAttributes(attributes, detector: detector)
            }
            
            let textColor = displayDelegate.textColor(for: message,
                                                      at: indexPath,
                                                      in: messagesCollectionView)
            messageLabel.text = chatMessage.text
            messageLabel.textColor = textColor
        }
        
        singleChoicesView.setSingleChoices(chatMessage.singleChoices ?? [])

        messageContainerView.backgroundColor = messageColor
        messageContainerView.style = messageStyle

        let topCellLabelText = dataSource.cellTopLabelAttributedText(for: message, at: indexPath)
        let bottomCellLabelText = dataSource.cellBottomLabelAttributedText(for: message, at: indexPath)
        let topMessageLabelText = dataSource.messageTopLabelAttributedText(for: message, at: indexPath)
        let bottomMessageLabelText = dataSource.messageBottomLabelAttributedText(for: message, at: indexPath)

        cellTopLabel.attributedText = topCellLabelText
        cellBottomLabel.attributedText = bottomCellLabelText
        messageTopLabel.attributedText = topMessageLabelText
        messageBottomLabel.attributedText = bottomMessageLabelText
    }

//    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
//        let touchLocation = gesture.location(in: self)
//
//        switch true {
//        case messageContainerView.frame.contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
//            delegate?.didTapMessage(in: self)
//        case avatarView.frame.contains(touchLocation):
//            delegate?.didTapAvatar(in: self)
//        case cellTopLabel.frame.contains(touchLocation):
//            delegate?.didTapCellTopLabel(in: self)
//        case cellBottomLabel.frame.contains(touchLocation):
//            delegate?.didTapCellBottomLabel(in: self)
//        case messageTopLabel.frame.contains(touchLocation):
//            delegate?.didTapMessageTopLabel(in: self)
//        case messageBottomLabel.frame.contains(touchLocation):
//            delegate?.didTapMessageBottomLabel(in: self)
//        case accessoryView.frame.contains(touchLocation):
//            delegate?.didTapAccessoryView(in: self)
//        default:
//            delegate?.didTapBackground(in: self)
//        }
//    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchPoint = gestureRecognizer.location(in: self)
        guard gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) else { return false }
        return messageContainerView.frame.contains(touchPoint)
    }

    func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return false
    }

    // MARK: - ORIGIN CALCULATIONS
    private func setupMessageLabel(with attributes: CustomMessagesCollectionViewLayoutAttributes) {
        messageLabel.textInsets = attributes.messageLabelInsets
        messageLabel.frame = messageContainerView.bounds
    }
    
    private func layoutAvatarView(with attributes: CustomMessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        let padding = attributes.avatarLeadingTrailingPadding

        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = padding
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width - padding
        case .natural:
            fatalError("AvatarPosition Horizontal.natural needs to be resolved.")
        }

        switch attributes.avatarPosition.vertical {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
        case .messageTop:
            origin.y = messageContainerView.frame.minY
        case .messageBottom:
            origin.y = messageContainerView.frame.maxY - attributes.avatarSize.height
        case .messageCenter:
            origin.y = messageContainerView.frame.midY - (attributes.avatarSize.height/2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.avatarSize.height
        default:
            break
        }

        avatarView.frame = CGRect(origin: origin, size: attributes.avatarSize)
    }

    private func layoutMessageContainerView(with attributes: CustomMessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero

        switch attributes.avatarPosition.vertical {
        case .messageBottom:
            origin.y = attributes.size.height - attributes.messageContainerPadding.bottom - attributes.cellBottomLabelSize.height - attributes.messageBottomLabelSize.height - attributes.messageContainerSize.height - attributes.additionalContainerSize.height - attributes.messageContainerPadding.top - 8
        case .messageCenter:
            if attributes.avatarSize.height > attributes.messageContainerSize.height {
                let messageHeight = attributes.messageContainerSize.height + attributes.additionalContainerSize.height + attributes.messageContainerPadding.top + attributes.messageContainerPadding.bottom
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                fallthrough
            }
        default:
            if attributes.accessoryViewSize.height > attributes.messageContainerSize.height {
                let messageHeight = attributes.messageContainerSize.height + attributes.additionalContainerSize.height + attributes.messageContainerPadding.top + attributes.messageContainerPadding.bottom
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                origin.y = attributes.cellTopLabelSize.height + attributes.messageTopLabelSize.height + attributes.messageContainerPadding.top
            }
        }

        let avatarPadding = attributes.avatarLeadingTrailingPadding
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = attributes.avatarSize.width + attributes.messageContainerPadding.left + avatarPadding
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width - attributes.messageContainerSize.width - attributes.messageContainerPadding.right - avatarPadding
        case .natural:
            fatalError("AvatarPosition Horizontal.natural needs to be resolved.")
        }

        messageContainerView.frame = CGRect(origin: origin, size: attributes.messageContainerSize)
    }
    
    private func layoutSingleChoicesView(with attributes: CustomMessagesCollectionViewLayoutAttributes) {
        let y = cellBottomLabel.frame.maxY + 8
        let avatarPadding = attributes.avatarLeadingTrailingPadding
        let originX: CGFloat = attributes.avatarSize.width + attributes.messageContainerPadding.left + avatarPadding - 8
        let origin = CGPoint(x: originX, y: y)

        singleChoicesView.frame = CGRect(origin: origin, size: attributes.additionalContainerSize)
    }

    private func layoutCellTopLabel(with attributes: CustomMessagesCollectionViewLayoutAttributes) {
        cellTopLabel.textAlignment = attributes.cellTopLabelAlignment.textAlignment
        cellTopLabel.textInsets = attributes.cellTopLabelAlignment.textInsets

        cellTopLabel.frame = CGRect(origin: .zero, size: attributes.cellTopLabelSize)
    }
    
    private func layoutCellBottomLabel(with attributes: CustomMessagesCollectionViewLayoutAttributes) {
        cellBottomLabel.textAlignment = attributes.cellBottomLabelAlignment.textAlignment
        cellBottomLabel.textInsets = attributes.cellBottomLabelAlignment.textInsets
        
        let y = messageBottomLabel.frame.maxY
        let origin = CGPoint(x: 0, y: y)
        
        cellBottomLabel.frame = CGRect(origin: origin, size: attributes.cellBottomLabelSize)
    }
    
    private func layoutMessageTopLabel(with attributes: CustomMessagesCollectionViewLayoutAttributes) {
        messageTopLabel.textAlignment = attributes.messageTopLabelAlignment.textAlignment
        messageTopLabel.textInsets = attributes.messageTopLabelAlignment.textInsets

        let y = messageContainerView.frame.minY - attributes.messageContainerPadding.top - attributes.messageTopLabelSize.height
        let origin = CGPoint(x: 0, y: y)
        
        messageTopLabel.frame = CGRect(origin: origin, size: attributes.messageTopLabelSize)
    }

    private func layoutMessageBottomLabel(with attributes: CustomMessagesCollectionViewLayoutAttributes) {
        messageBottomLabel.textAlignment = attributes.messageBottomLabelAlignment.textAlignment
        messageBottomLabel.textInsets = attributes.messageBottomLabelAlignment.textInsets

        let y = messageContainerView.frame.maxY
        let origin = CGPoint(x: 0, y: y)

        messageBottomLabel.frame = CGRect(origin: origin, size: attributes.messageBottomLabelSize)
    }

    private func layoutAccessoryView(with attributes: CustomMessagesCollectionViewLayoutAttributes) {
        
        var origin: CGPoint = .zero
        
        switch attributes.accessoryViewPosition {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
        case .messageTop:
            origin.y = messageContainerView.frame.minY
        case .messageBottom:
            origin.y = messageContainerView.frame.maxY - attributes.accessoryViewSize.height
        case .messageCenter:
            origin.y = messageContainerView.frame.midY - (attributes.accessoryViewSize.height / 2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.accessoryViewSize.height
        default:
            break
        }

        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = messageContainerView.frame.maxX + attributes.accessoryViewPadding.left
        case .cellTrailing:
            origin.x = messageContainerView.frame.minX - attributes.accessoryViewPadding.right - attributes.accessoryViewSize.width
        case .natural:
            fatalError("AvatarPosition Horizontal.natural needs to be resolved.")
        }

        accessoryView.frame = CGRect(origin: origin, size: attributes.accessoryViewSize)
    }
}


