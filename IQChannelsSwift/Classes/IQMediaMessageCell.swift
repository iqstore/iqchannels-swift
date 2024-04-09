//
//  IQMediaMessageCell.swift
//  IQChannelsSwift
//
//  Created by Daulet on 09.04.2024.
//

import UIKit
import MessageKit

class IQMediaMessageCell: MediaMessageCell {
    
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        messageContainerView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func configure(with message: any MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        switch message.kind {
        case .photo(let media):
            let hasImage = media.image != nil
            activityIndicator.isHidden = hasImage
            hasImage ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
        default: break
        }
    }
    
}
