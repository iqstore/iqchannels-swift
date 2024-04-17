//
//  IQAttachmentButton.swift
//  IQChannelsSwift
//
//  Created by Daulet on 31.03.2024.
//

import UIKit
import InputBarAccessoryView

class IQAttachmentButton: UIButton, InputItem {
    
    var inputBarAccessoryView: InputBarAccessoryView?
    
    var parentStackViewPosition: InputStackView.Position?
    
    func textViewDidChangeAction(with textView: InputTextView) { }
    
    func keyboardSwipeGestureAction(with gesture: UISwipeGestureRecognizer) { }
    
    func keyboardEditingEndsAction() { }
    
    func keyboardEditingBeginsAction() { }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .init(hex: 0xF4F4F8)
        setImage(.init(systemName: "paperclip"), for: .normal)
        imageView?.tintColor = .init(hex: 0x919399)
        snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
    }

}
