//
//  IQTypingIndicatorCell.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.04.2024.
//

import UIKit

class IQTypingIndicatorCell: UICollectionViewCell {
    
    var textLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .init(hex: 0x242729)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private var container: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: 0xF4F4F8)
        view.layer.cornerRadius = 12
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(container)
        container.addSubview(textLabel)
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(48)
            make.verticalEdges.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().inset(4)
        }
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textLabel.text = nil
    }
    
}
