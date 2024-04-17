import UIKit
import MessageKit

protocol IQCardCellDelegate: AnyObject {
    func cardCell(_ cell: IQCardCell, didSelectOption option: IQAction)
}

final class IQCardCell: MessageContentCell {

    // MARK: - PROPERTIES
    private var actions: [IQAction] = []
    private var buttonsArray: [UIButton] = []
    
    private var imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var messageLabel = MessageLabel()
    
    private var buttonsStackView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.axis = .vertical
        stackView.spacing = -1
        return stackView
    }()
    
    private var messageStackView: UIStackView = {
        let stackView: UIStackView = .init()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    weak var cardCellDelegate: IQCardCellDelegate?

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
    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(messageStackView)
        messageContainerView.isUserInteractionEnabled = true
        
        messageStackView.addArrangedSubview(messageLabel)
        messageStackView.addArrangedSubview(buttonsStackView)
        
        let imageViewWidthConstraint = NSLayoutConstraint(item: imageView,
                                                          attribute: .width,
                                                          relatedBy: .equal,
                                                          toItem: nil,
                                                          attribute: .notAnAttribute,
                                                          multiplier: 1,
                                                          constant: 210)
        let imageViewHeightConstraint = NSLayoutConstraint(item: imageView,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: nil,
                                                           attribute: .notAnAttribute,
                                                           multiplier: 1,
                                                           constant: 150)
        imageView.addConstraints([imageViewWidthConstraint, imageViewHeightConstraint])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
        imageView.image = nil
        messageStackView.removeArrangedSubview(imageView)
        setActions([])
    }

    // MARK: - CONFIGURATION
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? CustomMessagesCollectionViewLayoutAttributes else { return }
        
        layoutMessageStackView(with: attributes)
    }

    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError("MessagesDisplayDelegate has not been set.")
        }
        guard let message = message as? IQChatMessage else { return }
        
        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)

        messageLabel.configure {
            messageLabel.enabledDetectors = enabledDetectors
            for detector in enabledDetectors {
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                messageLabel.setAttributes(attributes, detector: detector)
            }
            switch message.kind {
            case .custom:
                let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
                messageLabel.text = message.text
                messageLabel.textColor = textColor
            default:
                break
            }
        }
        
        setActions(message.actions ?? [])
        
        if message.isMediaMessage {
            messageStackView.insertArrangedSubview(imageView, at: 0)
            if let image = message.media?.image {
                imageView.image = image
            } else {
                IQChannels.loadMessageMedia(message.id)
            }
        }

    }

    // MARK: - PRIVATE METHODS
    private func setActions(_ actions: [IQAction]) {
        self.actions = actions
        
        buttonsArray = []
        buttonsStackView.arrangedSubviews.forEach {
            buttonsStackView.removeArrangedSubview($0)
        }

        for action in actions {
            let button = getNewButton(withTitle: action.title ?? "")
            buttonsStackView.addArrangedSubview(button)
            buttonsArray.append(button)
        }
        
        layoutSubviews()
    }
    
    private func getNewButton(withTitle title: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        button.setTitleColor(.black, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = UIColor(red: 227.0/255, green: 227.0/255, blue: 227.0/255, alpha: 1)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        button.layer.borderColor = UIColor(red: 132.0/255, green: 132.0/255, blue: 132.0/255, alpha: 1).cgColor
        button.layer.borderWidth = 1
        return button
    }
    
    @objc
    private func buttonAction(_ button: UIButton) {
        guard let index = buttonsArray.firstIndex(of: button) else { return }
        cardCellDelegate?.cardCell(self, didSelectOption: actions[index])
    }

    // MARK: - ORIGIN CALCULATIONS
    private func layoutMessageStackView(with attributes: CustomMessagesCollectionViewLayoutAttributes) {
        messageStackView.isLayoutMarginsRelativeArrangement = true
        messageStackView.layoutMargins = attributes.messageLabelInsets
        messageStackView.frame = messageContainerView.bounds
    }
}


