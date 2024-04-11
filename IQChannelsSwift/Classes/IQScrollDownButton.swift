//
//  IQScrollDownButton.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.04.2024.
//

import UIKit

class IQScrollDownButton: UIButton {
    
    var dotHidden: Bool {
        get {
            dotView.isHidden
        } set {
            dotView.isHidden = newValue
        }
    }
    
    private var dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: 0xDD0A34)
        view.layer.cornerRadius = 4
        view.snp.makeConstraints { make in
            make.size.equalTo(8)
        }
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
    }
        
    private func setupView(){
        layer.borderColor = UIColor(hex: 0xE4E8ED).cgColor
        layer.borderWidth = 1
        backgroundColor = .white
        setImage(.init(systemName: "chevron.down"), for: .normal)
        imageView?.tintColor = .init(hex: 0x919399)
        
        addSubview(dotView)
    }
    
    private func setupConstraints(){
        snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        dotView.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(2)
        }
    }


}
