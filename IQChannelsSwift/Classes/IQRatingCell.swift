//
//  IQRatingCell.swift
//  IQChannelsSwift
//
//  Created by Daulet on 09.04.2024.
//

import UIKit
import MessageKit

protocol IQRatingCellDelegate: AnyObject {
    func cell(didTapSendButtonFrom cell: IQRatingCell, value: Int)
}

class IQRatingCell: IQTimestampMessageCell {
    
    weak var ratingDelegate: IQRatingCellDelegate?
    
    private lazy var ratingView: IQStarRatingView = {
        let view = IQStarRatingView()
        return view
    }()
    
    private lazy var sendButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 8
        button.backgroundColor = .init(hex: 0xDD0A34)
        button.setTitle("Отправить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.addTarget(self, action: #selector(sendDidTap), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        messageContainerView.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        dateLabel.isHidden = true
        messageContainerView.addSubview(sendButton)
        messageContainerView.addSubview(ratingView)
        sendButton.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.horizontalEdges.bottom.equalToSuperview().inset(12)
        }
        ratingView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.bottom.equalTo(sendButton.snp.top).inset(-20)
        }

    }
    
    @objc private func sendDidTap(){
        ratingDelegate?.cell(didTapSendButtonFrom: self, value: ratingView.rating)
    }

}
