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

class IQRatingCell: IQTimestampMessageCell, IQStarRatingViewDelegate {
    
    weak var ratingDelegate: IQRatingCellDelegate?
    
    private lazy var ratingView: IQStarRatingView = {
        let view = IQStarRatingView()
        view.delegate = self
        return view
    }()
    
    private lazy var sendButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 8
        button.setTitle("Отправить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.addTarget(self, action: #selector(sendDidTap), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
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
        timestampView.isHidden = true
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
        setSendButton(enabled: false)
    }
    
    func ratingView(_ ratingView: IQStarRatingView, didSet rating: Int) {
        setSendButton(enabled: true)
    }
    
    @objc private func sendDidTap(){
        ratingDelegate?.cell(didTapSendButtonFrom: self, value: ratingView.rating)
    }
    
    private func setSendButton(enabled: Bool) {
        sendButton.isEnabled = enabled
        if enabled {
            sendButton.backgroundColor = .init(hex: 0xDD0A34)
        } else {
            sendButton.backgroundColor = .init(hex: 0xB7B7CA)
        }
    }

}
