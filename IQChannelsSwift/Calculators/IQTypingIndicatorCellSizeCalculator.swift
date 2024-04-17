//
//  IQTypingIndicatorCellSizeCalculator.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.04.2024.
//

import UIKit
import MessageKit

class IQTypingIndicatorCellSizeCalculator: MessageSizeCalculator {
    
    override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        return .init(width: messagesLayout.itemWidth, height: 40)
    }
    
}
