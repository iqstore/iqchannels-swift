//
//  IQTimestampMessageCell.swift
//  IQChannelsSwift
//
//  Created by Daulet on 31.03.2024.
//

import UIKit
import SnapKit
import MessageKit

class IQTimestampMessageCell: TextMessageCell {
    
    var timestampView = IQTimestampView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        messageContainerView.addSubview(timestampView)
        timestampView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    override func configure(with message: any MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        timestampView.configure(with: message)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
