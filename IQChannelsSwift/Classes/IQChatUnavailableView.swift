//
//  IQChatUnavailableView.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.04.2024.
//

import UIKit

class IQChatUnavailableView: UIStackView {
    
    private var xmarkImageView = UIImageView(image: UIImage(named: "xmarkCircle", in: .channelsAssetBundle(), with: nil))
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Чат временно недоступен"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .init(hex: 0x242729)
        label.textAlignment = .center
        return label
    }()
    
    private var bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "Мы уже все исправляем. Обновите\nстраницу или попробуйте позже"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .init(hex: 0x242729)
        label.textAlignment = .center
        return label
    }()

    private lazy var labelsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
        
    private func setupViews(){
        axis = .vertical
        spacing = 24
        alignment = .center
        
        addArrangedSubview(xmarkImageView)
        addArrangedSubview(labelsStackView)
    }
    
    private func setupConstraints(){
        xmarkImageView.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
    }
   
}
