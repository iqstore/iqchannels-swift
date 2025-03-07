//
//  SystemMessageCellView.swift
//  Pods
//
//  Created by  Mikhail Zinkov on 11.11.2024.
//

import SwiftUI

struct SystemMessageCellView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    private let message: IQMessage
    
    var textColor: UIColor {
        return Style.getUIColor(theme: Style.model?.chat?.systemText?.color) ?? UIColor(hex: "888888")
    }
    var fontSize: CGFloat {
        return CGFloat(Style.model?.chat?.systemText?.textSize ?? 17)
    }
    var isBold: Bool {
        return Style.model?.chat?.systemText?.textStyle?.bold ?? false
    }
    var isItalic: Bool {
        return Style.model?.chat?.systemText?.textStyle?.italic ?? false
    }
    var aligment: TextAlignment {
        return stringToAlignment(stringAlignment: Style.model?.chat?.systemText?.textAlign) ?? .leading
    }
    
    var backgroundColor: Color {
        return Style.getColor(theme: Style.model?.rating?.backgroundContainer?.color) ?? Color(hex: "F4F4F8")
    }
    
    // MARK: - INIT
    init(message: IQMessage) {
        self.message = message
    }
    
    // MARK: - BODY
    var body: some View {
        let data = AttributeTextManager.shared.getString(from: message.messageText,
                                                         textColor: textColor,
                                                         fontSize: fontSize,
                                                         alingment: aligment,
                                                         isBold: isBold,
                                                         isItalic: isItalic)
        TextLabel(text: data.0,
                  linkRanges: data.1)
        .layoutPriority(1)
        .padding(.vertical, 8)
    }
}
