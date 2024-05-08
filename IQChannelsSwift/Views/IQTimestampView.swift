//
//  IQTimestampView.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.04.2024.
//

import UIKit
import SnapKit
import MessageKit

class IQTimestampView: UIView {
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    private let readImageView = UIImageView()
    
    let dateLabel = UILabel()
    
    private var labelToImageConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(dateLabel)
        addSubview(readImageView)
        dateLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().priority(999)
            labelToImageConstraint = make.right.equalTo(readImageView.snp.left).inset(-4).constraint
            make.verticalEdges.left.equalToSuperview()
        }
        readImageView.snp.makeConstraints { make in
            make.verticalEdges.right.equalToSuperview()
            make.size.equalTo(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with message: any MessageType) {
        guard let message = message as? IQChatMessage else { return }

        var textColor: UIColor {
                return message.isMy ? UIColor.white.withAlphaComponent(0.63) : .init(hex: 0x919399)
        }
        let attributedString = NSMutableAttributedString()
        attributedString.append(.init(string: dateFormatter.string(from: message.sentDate),
                                      attributes: [.font: UIFont.systemFont(ofSize: 13),
                                                   .foregroundColor: textColor]))
        dateLabel.attributedText = attributedString
        
        let messageSent = (message.id != 0) || message.sent
        var imageViewShown: Bool {
            guard message.isMy else { return false }
            
            return !(!messageSent && message.payload != .text)
        }
        readImageView.isHidden = !imageViewShown
        labelToImageConstraint?.isActive = imageViewShown
        
        if message.isMy {
            if messageSent {
                readImageView.stopRotating()
                let doubleCheckmarkImage = UIImage(named: "doubleCheckmark", in: .channelsAssetBundle(), with: nil)
                let singleCheckmarkImage = UIImage(named: "singleCheckmark", in: .channelsAssetBundle(), with: nil)
                readImageView.image = message.read ? doubleCheckmarkImage : singleCheckmarkImage
            } else {
                readImageView.image = UIImage(named: "loader", in: .channelsAssetBundle(), with: nil)
                readImageView.startRotating()
            }
        }
    }
}
