//
//  IQStarRatingView.swift
//  IQChannelsSwift
//
//  Created by Daulet on 09.04.2024.
//

import UIKit

class IQStarRatingView: UIStackView {
    
    var rating: Int = 0 {
        didSet {
            updateRating()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        axis = .horizontal
        distribution = .fillEqually
        spacing = 7
        for _ in 1...5 {
            let starButton = UIButton()
            starButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
            starButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .selected)
            starButton.setImage(UIImage(systemName: "star"), for: .normal)
            starButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
            starButton.imageView?.tintColor = .init(hex: 0xFCBB14)
            starButton.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            addArrangedSubview(starButton)
        }
        
        updateRating()
    }
    
    private func updateRating() {
        for (index, subview) in arrangedSubviews.enumerated() {
            if let starButton = subview as? UIButton {
                starButton.isSelected = index < rating
            }
        }
    }
    
    @objc private func starButtonTapped(_ sender: UIButton) {
        guard let index = arrangedSubviews.firstIndex(of: sender) else {
            return
        }
        
        rating = index + 1
    }

}
