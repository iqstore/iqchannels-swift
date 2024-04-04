//
//  IQTimestampMessageCell.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 31.03.2024.
//

import UIKit
import SnapKit
import MessageKit

class IQTimestampMessageCell: TextMessageCell {
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    private let readImageView = UIImageView(image: .init(named: "doubleCheckmark"))
    
    private let dateLabel = UILabel()
    
    private var labelToImageConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        messageContainerView.addSubview(dateLabel)
        messageContainerView.addSubview(readImageView)
        dateLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12).priority(999)
            labelToImageConstraint = make.right.equalTo(readImageView.snp.left).inset(-4).constraint
            make.bottom.equalToSuperview().inset(8)
        }
        readImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
            make.size.equalTo(16)
        }
    }
    
    override func configure(with message: any MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let message = message as? IQChatMessage else { return }
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(.init(string: dateFormatter.string(from: message.sentDate),
                                      attributes: [.font: UIFont.systemFont(ofSize: 13),
                                                   .foregroundColor: message.isMy ? UIColor.white.withAlphaComponent(0.63) : .init(hex: 0x919399)]))
        dateLabel.attributedText = attributedString
        
        readImageView.isHidden = !(message.isMy && message.read)
        labelToImageConstraint?.isActive = message.isMy && message.read
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
