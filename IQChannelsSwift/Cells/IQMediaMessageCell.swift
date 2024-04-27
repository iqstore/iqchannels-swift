//
//  IQMediaMessageCell.swift
//  IQChannelsSwift
//
//  Created by Daulet on 09.04.2024.
//

import UIKit
import MessageKit
import SnapKit

class IQMediaMessageCell: MessageContentCell {
    
    private var timestampView = IQTimestampView()
    
    private var replyView = IQCellReplyView()
    
    weak var replyViewDelegate: IQCellReplyViewDelegate?
    
    private var imageToReplyConstraint: Constraint?
    
    open var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var timestampContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: 0x242729).withAlphaComponent(0.56)
        return view
    }()
    
    private var activityIndicator: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "loaderBig",
                                                  in: .channelsAssetBundle(),
                                                  compatibleWith: nil))
        imageView.backgroundColor = .init(hex: 0x242729).withAlphaComponent(0.56)
        imageView.layer.cornerRadius = 38 / 2
        imageView.clipsToBounds = true
        return imageView
    }()

    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(imageView)
        messageContainerView.addSubview(replyView)
        imageView.addSubview(activityIndicator)
        messageContainerView.addSubview(timestampContainer)
        timestampContainer.addSubview(timestampView)
        messageContainerView.isUserInteractionEnabled = true
        setupConstraints()
    }
    
    private func setupConstraints(){
        replyView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().priority(.high)
           imageToReplyConstraint = make.top.equalTo(replyView.snp.bottom).constraint
            make.horizontalEdges.bottom.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.size.equalTo(38)
            make.center.equalToSuperview()
        }
        timestampView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
        }
        timestampContainer.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let message = message as? IQChatMessage else { return }
        
        if case MessageKind.photo(let mediaItem) = message.kind {
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            let hasImage = mediaItem.image != nil
            activityIndicator.isHidden = hasImage
            hasImage ? activityIndicator.stopRotating() : activityIndicator.startRotating()
        }
                
        timestampView.configure(with: message)
        replyView.configure(with: message)
        replyView.isHidden = message.replyToMessage == nil
        imageToReplyConstraint?.isActive = message.replyToMessage != nil
        contentView.layoutIfNeeded()
        timestampContainer.layer.cornerRadius = timestampContainer.frame.height / 2
        
        if let delegate = messagesCollectionView.messagesDisplayDelegate {
            replyView.backgroundColor = delegate.backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
        }
    }
    
    /// Handle tap gesture on contentView and its subviews.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: messageContainerView)
        
        if !replyView.isHidden, replyView.frame.contains(touchLocation){
            replyViewDelegate?.cell(self, didTapReplyView: replyView)
            return
        }
        
        if imageView.frame.contains(touchLocation) {
            delegate?.didTapImage(in: self)
            return
        }

        super.handleTapGesture(gesture)
    }
    
}
