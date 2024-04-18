//
//  IQStarRatingView.swift
//  IQChannelsSwift
//
//  Created by Daulet on 09.04.2024.
//

import UIKit

protocol IQStarRatingViewDelegate: AnyObject {
    func ratingView(_ ratingView: IQStarRatingView, didSet rating: Int)
}

class IQStarRatingView: UIStackView {
    
    var rating: Int = 0 {
        didSet {
            updateRating()
        }
    }
    
    weak var delegate: IQStarRatingViewDelegate?
    
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
            starButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 40), forImageIn: .normal)
            starButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 40), forImageIn: .selected)
            starButton.setImage(UIImage(systemName: "star.fill")?.withTintColor(.init(hex: 0xDBDBE2), renderingMode: .alwaysOriginal), for: .normal)
            starButton.setImage(UIImage(systemName: "star.fill")?.withTintColor(.init(hex: 0xFCBB14), renderingMode: .alwaysOriginal), for: .selected)
            starButton.imageView?.tintColor = .init(hex: 0xFCBB14)
            starButton.imageView?.contentMode = .scaleAspectFit
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
        delegate?.ratingView(self, didSet: rating)
    }

}
