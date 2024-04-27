//
//  IQTimestampMessageCell.swift
//  IQChannelsSwift
//
//  Created by Daulet on 31.03.2024.
//

import UIKit
import SnapKit
import MessageKit

protocol IQCellReplyViewDelegate: AnyObject {
    func cell(_ cell: MessageContentCell, didTapReplyView: IQCellReplyView)
}

class IQTimestampMessageCell: TextMessageCell {
    
    weak var replyViewDelegate: IQCellReplyViewDelegate?
    
    var timestampView = IQTimestampView()
    
    var replyView = IQCellReplyView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        messageContainerView.addSubview(timestampView)
        messageContainerView.addSubview(replyView)
        timestampView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
        replyView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
        }
        messageContainerView.isUserInteractionEnabled = true
        replyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(replyViewDidTap)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure(with message: any MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let message = message as? IQChatMessage else { return }

        timestampView.configure(with: message)
        replyView.configure(with: message)
        replyView.isHidden = message.replyToMessage == nil
    }
    
    @objc private func replyViewDidTap(){
        replyViewDelegate?.cell(self, didTapReplyView: replyView)
    }
    
}
