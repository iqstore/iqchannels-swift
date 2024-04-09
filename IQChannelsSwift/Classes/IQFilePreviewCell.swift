import UIKit
import MessageKit

final class IQFilePreviewCell: MessageContentCell {
    
    override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }

    var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        return stackView
    }()
    var messageLabel = MessageLabel()
    var fileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "doc")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            contentStackView.frame = messageContainerView.bounds
            contentStackView.isLayoutMarginsRelativeArrangement = true
            contentStackView.layoutMargins = attributes.messageLabelInsets
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
    }

    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(fileImageView)
        contentStackView.addArrangedSubview(messageLabel)
        
        fileImageView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
    }

    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError("MessagesDisplayDelegate has not been set.")
        }
        
        guard let chatMessage = message as? IQChatMessage else { return }
        
        fileImageView.tintColor = chatMessage.isMy ? .white : .black

        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)

        messageLabel.configure {
            messageLabel.enabledDetectors = enabledDetectors
            for detector in enabledDetectors {
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                messageLabel.setAttributes(attributes, detector: detector)
            }
            
            let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
            messageLabel.text = chatMessage.text
            messageLabel.textColor = textColor
        }
    }
}
