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
        return IQStyle.getColor(theme: IQStyle.model?.rating?.backgroundContainer?.color) ?? Color(hex: "F4F4F8")
    }
    var backgroundRadius: CGFloat {
        return IQStyle.model?.rating?.backgroundContainer?.border?.borderRadius ?? 12
    }
    var backgroundBorderSize: CGFloat {
        return IQStyle.model?.rating?.backgroundContainer?.border?.size ?? 0
    }
    var backgroundBorderColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.rating?.backgroundContainer?.border?.color) ?? Color(hex: "000000")
    }
    
    
    
    
    var titleColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.rating?.ratingTitle?.color) ?? Color(hex: "242729")
    }
    var titleFontSize: CGFloat {
        return CGFloat(IQStyle.model?.rating?.ratingTitle?.textSize ?? 17)
    }
    var titleIsBold: Bool {
        return IQStyle.model?.rating?.ratingTitle?.textStyle?.bold ?? false
    }
    var titleIsItalic: Bool {
        return IQStyle.model?.rating?.ratingTitle?.textStyle?.italic ?? false
    }
    var titleAlignment: TextAlignment {
        return stringToAlignment(stringAlignment: IQStyle.model?.rating?.ratingTitle?.textAlign) ?? .center
    }
    
    
    // MARK: - BODY
    var body: some View {
        let disabledRatingTextColor = IQStyle.getColor(theme: IQStyle.model?.rating?.answerButton?.textDisabled?.color) ?? Color.white
        let disabledRatingFontSize = CGFloat(IQStyle.model?.rating?.answerButton?.textDisabled?.textSize ?? 15)
        let disabledRatingBackgroundColor = IQStyle.getColor(theme: IQStyle.model?.rating?.answerButton?.backgroundDisabled?.color) ?? Color(hex: "B7B7CA")
        
        let disabledRatingIsBold = IQStyle.model?.rating?.answerButton?.textDisabled?.textStyle?.bold ?? false
        let disabledRatingIsItalic = IQStyle.model?.rating?.answerButton?.textDisabled?.textStyle?.italic ?? false
        let disabledRatingAlignment = stringToAlignment(stringAlignment: IQStyle.model?.rating?.answerButton?.textDisabled?.textAlign) ?? .center
        
        let disabledRatingRadius = IQStyle.model?.rating?.answerButton?.backgroundDisabled?.border?.borderRadius ?? 8
        let disabledRatingBorderSize = IQStyle.model?.rating?.answerButton?.backgroundDisabled?.border?.size ?? 0
        let disabledRatingBorderColor = IQStyle.getColor(theme: IQStyle.model?.rating?.answerButton?.backgroundDisabled?.border?.color) ?? Color(hex: "000000")
        
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
                        .foregroundColor(disabledRatingTextColor)
                        .font(.system(size: disabledRatingFontSize))
                        .bold(disabledRatingIsBold)
                        .italic(disabledRatingIsItalic)
                        .multilineTextAlignment(disabledRatingAlignment)
                        .frame(maxWidth: .infinity, alignment:
                                textAlignmentToAlignment(textAlignment: disabledRatingAlignment) ?? .center
                        )
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(disabledRatingBackgroundColor)
                        .cornerRadius(disabledRatingRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: disabledRatingRadius)
                                .stroke(
                                    disabledRatingBorderColor,
                                    lineWidth: disabledRatingBorderSize)
                        )
                } else {
                    Text("Перейти в канал \"\(message.transferToChannel?.title ?? "")\"")
                        .foregroundColor(disabledRatingTextColor)
                        .font(.system(size: disabledRatingFontSize))
                        .multilineTextAlignment(disabledRatingAlignment)
                        .frame(maxWidth: .infinity, alignment:
                                textAlignmentToAlignment(textAlignment: disabledRatingAlignment) ?? .center
                        )
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(disabledRatingBackgroundColor)
                        .cornerRadius(disabledRatingRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: disabledRatingRadius)
                                .stroke(
                                    disabledRatingBorderColor,
                                    lineWidth: disabledRatingBorderSize)
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
