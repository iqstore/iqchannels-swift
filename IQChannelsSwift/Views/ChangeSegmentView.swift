//
//  ChangeSegmentView.swift
//  Pods
//
//  Created by Mikhail Zinkov on 01.12.2025.
//

import SwiftUI
import SDWebImageSwiftUI

private var pollResult: [IQRatingPollClientAnswerInput] = []

struct ChangeSegmentView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let message: IQMessage
    let segmentChanged: (() -> Void)
    
    var cellWidth: CGFloat {
        return UIScreen.screenWidth - 50
    }
    
    
    
    var backgroundColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.changeSegment?.backgroundContainer?.color) ?? Color(hex: "F4F4F8")
    }
    var backgroundRadius: CGFloat {
        return IQStyle.model?.changeSegment?.backgroundContainer?.border?.borderRadius ?? 12
    }
    var backgroundBorderSize: CGFloat {
        return IQStyle.model?.changeSegment?.backgroundContainer?.border?.size ?? 0
    }
    var backgroundBorderColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.changeSegment?.backgroundContainer?.border?.color) ?? Color(hex: "000000")
    }
    
    
    
    
    var titleColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.changeSegment?.title?.color) ?? Color(hex: "242729")
    }
    var titleFontSize: CGFloat {
        return CGFloat(IQStyle.model?.changeSegment?.title?.textSize ?? 17)
    }
    var titleIsBold: Bool {
        return IQStyle.model?.changeSegment?.title?.textStyle?.bold ?? false
    }
    var titleIsItalic: Bool {
        return IQStyle.model?.changeSegment?.title?.textStyle?.italic ?? false
    }
    var titleAlignment: TextAlignment {
        return stringToAlignment(stringAlignment: IQStyle.model?.changeSegment?.title?.textAlign) ?? .center
    }
    
    
    // MARK: - BODY
    var body: some View {
        let buttonTextColor = IQStyle.getColor(theme: IQStyle.model?.changeSegment?.textButton?.color) ?? Color.white
        let buttonFontSize = CGFloat(IQStyle.model?.changeSegment?.textButton?.textSize ?? 15)
        let buttonBackgroundColor = IQStyle.getColor(theme: IQStyle.model?.changeSegment?.backgroundButton?.color) ?? Color(hex: "DD0A34")
        
        let buttonIsBold = IQStyle.model?.changeSegment?.textButton?.textStyle?.bold ?? false
        let buttonIsItalic = IQStyle.model?.changeSegment?.textButton?.textStyle?.italic ?? false
        let buttonAlignment = stringToAlignment(stringAlignment: IQStyle.model?.changeSegment?.textButton?.textAlign) ?? .center
        
        let buttonRadius = IQStyle.model?.changeSegment?.backgroundButton?.border?.borderRadius ?? 8
        let buttonBorderSize = IQStyle.model?.changeSegment?.backgroundButton?.border?.size ?? 0
        let buttonBorderColor = IQStyle.getColor(theme: IQStyle.model?.changeSegment?.backgroundButton?.border?.color) ?? Color(hex: "000000")
        
        VStack(spacing: 12) {
            if #available(iOS 16.0, *) {
                Text(message.text ?? "")
                        .foregroundColor(titleColor)
                        .font(.system(size: titleFontSize))
                        .bold(titleIsBold)
                        .italic(titleIsItalic)
                        .multilineTextAlignment(titleAlignment)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, alignment: textAlignmentToAlignment(textAlignment: titleAlignment) ?? .center)
            } else {
                Text(message.text ?? "")
                        .foregroundColor(titleColor)
                        .font(.system(size: titleFontSize))
                        .multilineTextAlignment(titleAlignment)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, alignment: textAlignmentToAlignment(textAlignment: titleAlignment) ?? .center)
            }
            
            Button {
                segmentChanged()
            } label: {
                if #available(iOS 16.0, *) {
                    Text("Перейти в канал \"\(message.transferToChannel?.title ?? "")\"")
                        .foregroundColor(buttonTextColor)
                        .font(.system(size: buttonFontSize))
                        .bold(buttonIsBold)
                        .italic(buttonIsItalic)
                        .multilineTextAlignment(buttonAlignment)
                        .frame(maxWidth: .infinity, alignment:
                                textAlignmentToAlignment(textAlignment: buttonAlignment) ?? .center
                        )
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(buttonBackgroundColor)
                        .cornerRadius(buttonRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: buttonRadius)
                                .stroke(
                                    buttonBorderColor,
                                    lineWidth: buttonBorderSize)
                        )
                } else {
                    Text("Перейти в канал \"\(message.transferToChannel?.title ?? "")\"")
                        .foregroundColor(buttonTextColor)
                        .font(.system(size: buttonFontSize))
                        .multilineTextAlignment(buttonAlignment)
                        .frame(maxWidth: .infinity, alignment:
                                textAlignmentToAlignment(textAlignment: buttonAlignment) ?? .center
                        )
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(buttonBackgroundColor)
                        .cornerRadius(buttonRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: buttonRadius)
                                .stroke(
                                    buttonBorderColor,
                                    lineWidth: buttonBorderSize)
                        )
                }
            }
        }
        .frame(width: cellWidth)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(backgroundColor)
        .cornerRadius(backgroundRadius)
        .overlay(
            RoundedRectangle(cornerRadius: backgroundRadius)
                .stroke(backgroundBorderColor, lineWidth: backgroundBorderSize)
        )
    }
}
