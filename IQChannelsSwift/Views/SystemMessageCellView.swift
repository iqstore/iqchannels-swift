//
//  SystemMessageCellView.swift
//  Pods
//
//  Created by  Mikhail Zinkov on 11.11.2024.
//

import SwiftUI

struct SystemMessageCellView: View {
    
    // MARK: - PROPERTIES
    private let message: IQMessage
    
    var textColor: UIColor {
        let textSystem = Style.getUIColor(theme: Style.model?.chat?.systemText?.color) ?? UIColor(hex: "888888")
        return textSystem
    }
    
    var fontSize: CGFloat {
        let sizeSystem = CGFloat(Style.model?.chat?.systemText?.textSize ?? 17)
        return sizeSystem
    }
    
    var backgroundColor: Color {
        return Style.getColor(theme: Style.model?.rating?.backgroundContainer) ?? Color(hex: "F4F4F8")
    }
    
    // MARK: - INIT
    init(message: IQMessage) {
        self.message = message
    }
    
    // MARK: - BODY
    var body: some View {
        let data = AttributeTextManager.shared.getString(from: message.messageText,
                                                         textColor: textColor,
                                                         fontSize: fontSize)
        TextLabel(text: data.0,
                  linkRanges: data.1)
        .layoutPriority(1)
        .padding(.vertical, 8)
    }
}
