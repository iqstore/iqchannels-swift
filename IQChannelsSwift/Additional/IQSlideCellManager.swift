//
//  IQSlideCellManager.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 21.04.2024.
//

import UIKit
import MessageKit

protocol IQSlideCellManagerDelegate: AnyObject {
    func slideManager(_ manager: IQSlideCellManager, slideDidOccurAt cell: MessageContentCell)
}

class IQSlideCellManager: NSObject, UIGestureRecognizerDelegate {
    
    var delegate: IQSlideCellManagerDelegate?
    
    private var cells: Set<MessageContentCell> = []
    
    func add(_ cell: MessageContentCell) {
        if cells.contains(cell) {
            cell.gestureRecognizers?.removeAll(where: { $0 is PanGestureRecognizer })
            cell.contentView.viewWithTag(-9999)?.removeFromSuperview()
        } else {
            cells.insert(cell)
        }
        let gr = PanGestureRecognizer(target: self, action: #selector(panDidDetect))
        gr.delegate = self
        cell.addGestureRecognizer(gr)
        addReplyView(to: cell)
    }
    
    private func addReplyView(to cell: MessageContentCell){
        let imageView = UIImageView(image: UIImage(named: "replyTag", in: .channelsAssetBundle(), with: nil))
        imageView.tag = -9999
        imageView.alpha = 0
        cell.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(cell.messageContainerView)
            make.left.equalTo(cell.messageContainerView.snp.right).inset(-24)
            make.size.equalTo(32)
        }
    }
    
    @objc
    private func panDidDetect(_ gesture: UIPanGestureRecognizer) {
        guard let slidingView = gesture.view as? MessageContentCell,
              let superView = slidingView.superview else { return }
        
        let replyTag = slidingView.contentView.viewWithTag(-9999)
        let translation = gesture.translation(in: superView)

        switch gesture.state {
        case .began:
            break
        case .changed:
            guard translation.x < 0 else { return }
            
            if let scrollView = superView as? UIScrollView,
               scrollView.isDragging || scrollView.isDecelerating /*|| scrollView.isTracking*/ {
                gesture.setTranslation(.zero, in: superView)
                return
            }
            
            if translation.x < -150 {
                gesture.setTranslation(translation, in: superView)
                return
            }
            
            let newTransform = CGAffineTransform(translationX: translation.x, y: 0)
            slidingView.transform = newTransform
            UIView.animate(withDuration: 0.2) {
                replyTag?.alpha = translation.x < -10 ? 1 : 0
            }
        case .ended, .cancelled:
            if translation.x < -50 {
                delegate?.slideManager(self, slideDidOccurAt: slidingView)
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseInOut]) {
                slidingView.transform = .identity
                replyTag?.alpha = 0
            }
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is UIScrollView,
           (gestureRecognizer.state == .changed),
           (otherGestureRecognizer.state == .possible || otherGestureRecognizer.state == .began || otherGestureRecognizer.state == .changed) {
            return false
        }
        return true
    }
    
}

fileprivate class PanGestureRecognizer: UIPanGestureRecognizer {
    
}
