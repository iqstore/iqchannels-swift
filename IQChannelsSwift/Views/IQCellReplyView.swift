//
//  IQCellReplyView.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 26.04.2024.
//

import UIKit
import MessageKit

class IQCellReplyView: UIView {
            
    private let sideLine: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 2, height: 32))
        }
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let authorLabel: UILabel = {
       let label = UILabel()
        label.textColor = .init(hex: 0x919399)
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private let messageLabel: UILabel = {
       let label = UILabel()
        label.textColor = .init(hex: 0x242729)
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [authorLabel, messageLabel])
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var stackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [sideLine, imageView, labelsStackView])
        stackView.spacing = 8
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 8, left: 12, bottom: 8, right: 12)
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with message: any MessageType) {
        guard let message = message as? IQChatMessage,
              let replyMessage = message.replyToMessage else { return }

        messageLabel.text = replyMessage.text
        authorLabel.text = replyMessage.chatMessageSenderDisplayName()
        
        if replyMessage.isMediaMessage,
           let url = replyMessage.file?.url {
            if let uploadImage = replyMessage.uploadImage {
                imageView.image = uploadImage
            } else {
                imageView.sd_setImage(with: url)
            }
            imageView.isHidden = false
            messageLabel.text = "Фотография"
        } else {
            imageView.image = nil
            imageView.isHidden = true
        }
        if message.isMy {
            sideLine.backgroundColor = .white
            authorLabel.textColor = .white
            messageLabel.textColor = .white.withAlphaComponent(0.64)
        } else {
            sideLine.backgroundColor = .init(hex: 0xDD0A34)
            authorLabel.textColor = .init(hex: 0x242729)
            messageLabel.textColor = .init(hex: 0x919399)
        }
    }
    
    private func setupViews(){
        backgroundColor = .clear
        addSubview(stackView)
    }
    
    private func setupConstraints(){
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
    }

}
