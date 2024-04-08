//
//  IQActivityIndicator.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 04.04.2024.
//

import UIKit

class IQActivityIndicator: UIStackView {
    
    var label: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 13)
        label.textColor = .init(hex: 0x555555)
        return label
    }()
    
    private var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .medium)
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    func startAnimating() {
        indicator.startAnimating()
        isHidden = false
    }
    
    func stopAnimating() {
        indicator.stopAnimating()
        isHidden = true
    }
    
    private func setupViews(){
        alpha = 0.8
        axis = .horizontal
        spacing = 6
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 16, left: 8, bottom: 16, right: 8)
        
        addArrangedSubview(label)
        addArrangedSubview(indicator)
    }
    
}
