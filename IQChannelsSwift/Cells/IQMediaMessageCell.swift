//
//  IQMediaMessageCell.swift
//  IQChannelsSwift
//
//  Created by Daulet on 09.04.2024.
//

import UIKit
import MessageKit

class IQMediaMessageCell: MediaMessageCell {
    
    var timestampView = IQTimestampView()
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        messageContainerView.addSubview(activityIndicator)
        messageContainerView.addSubview(timestampContainer)
        timestampContainer.addSubview(timestampView)
        
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func configure(with message: any MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        timestampView.configure(with: message)
        
        switch message.kind {
        case .photo(let media):
            let hasImage = media.image != nil
            activityIndicator.isHidden = hasImage
            hasImage ? activityIndicator.stopRotating() : activityIndicator.startRotating()
        default: break
        }
        contentView.layoutIfNeeded()
        timestampContainer.layer.cornerRadius = timestampContainer.frame.height / 2
    }
    
}
