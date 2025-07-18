//
//  SentRatingButton.swift
//  Pods
//
//  Created by Mikhail Zinkov on 05.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct SentRatingButton: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let disabled: Bool
    let action: () -> Void
    
    // MARK: - BODY
    var body: some View {
        let enabledRatingTextColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.textEnabled?.color) ?? Color.white
        let disabledRatingTextColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.textDisabled?.color) ?? Color.white
        let enabledRatingFontSize = CGFloat(IQStyle.model?.rating?.sentRating?.textEnabled?.textSize ?? 15)
        let disabledRatingFontSize = CGFloat(IQStyle.model?.rating?.sentRating?.textDisabled?.textSize ?? 15)
        
        
        let enabledRatingIsBold = IQStyle.model?.rating?.sentRating?.textEnabled?.textStyle?.bold ?? false
        let disabledRatingIsBold = IQStyle.model?.rating?.sentRating?.textDisabled?.textStyle?.bold ?? false
        let enabledRatingIsItalic = IQStyle.model?.rating?.sentRating?.textEnabled?.textStyle?.italic ?? false
        let disabledRatingIsItalic = IQStyle.model?.rating?.sentRating?.textDisabled?.textStyle?.italic ?? false
        let enabledRatingAlignment = stringToAlignment(stringAlignment: IQStyle.model?.rating?.sentRating?.textEnabled?.textAlign) ?? .center
        let disabledRatingAlignment = stringToAlignment(stringAlignment: IQStyle.model?.rating?.sentRating?.textDisabled?.textAlign) ?? .center
        
        
        let enabledRatingBackgroundColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.backgroundEnabled?.color) ?? Color(hex: "DD0A34")
        let disabledRatingBackgroundColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.backgroundDisabled?.color) ?? Color(hex: "B7B7CA")
        let enabledRatingRadius = IQStyle.model?.rating?.sentRating?.backgroundEnabled?.border?.borderRadius ?? 8
        let disabledRatingRadius = IQStyle.model?.rating?.sentRating?.backgroundDisabled?.border?.borderRadius ?? 8
        let enabledRatingBorderSize = IQStyle.model?.rating?.sentRating?.backgroundEnabled?.border?.size ?? 0
        let disabledRatingBorderSize = IQStyle.model?.rating?.sentRating?.backgroundDisabled?.border?.size ?? 0
        let enabledRatingBorderColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.backgroundEnabled?.border?.color) ?? Color(hex: "000000")
        let disabledRatingBorderColor = IQStyle.getColor(theme: IQStyle.model?.rating?.sentRating?.backgroundDisabled?.border?.color) ?? Color(hex: "000000")
        
        
        Button {
            if(!disabled){
                action()
            }
        } label: {
            if #available(iOS 16.0, *) {
                Text(IQLanguageTexts.model.sentRating ?? "Отправить")
                    .foregroundColor(disabled ? disabledRatingTextColor : enabledRatingTextColor)
                    .font(.system(size: disabled ? disabledRatingFontSize : enabledRatingFontSize))
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .bold(disabled ? disabledRatingIsBold : enabledRatingIsBold)
                    .italic(disabled ? disabledRatingIsItalic : enabledRatingIsItalic)
                    .multilineTextAlignment(disabled ? disabledRatingAlignment : enabledRatingAlignment)
                    .background(disabled ? disabledRatingBackgroundColor : enabledRatingBackgroundColor)
                    .cornerRadius(disabled ? disabledRatingRadius : enabledRatingRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: disabled ? disabledRatingRadius : enabledRatingRadius)
                            .stroke(
                                disabled ? disabledRatingBorderColor : enabledRatingBorderColor,
                                lineWidth: disabled ? disabledRatingBorderSize : enabledRatingBorderSize)
                    )
            } else {
                Text(IQLanguageTexts.model.sentRating ?? "Отправить")
                    .foregroundColor(disabled ? disabledRatingTextColor : enabledRatingTextColor)
                    .font(.system(size: disabled ? disabledRatingFontSize : enabledRatingFontSize))
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(disabled ? disabledRatingAlignment : enabledRatingAlignment)
                    .background(disabled ? disabledRatingBackgroundColor : enabledRatingBackgroundColor)
                    .cornerRadius(disabled ? disabledRatingRadius : enabledRatingRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: disabled ? disabledRatingRadius : enabledRatingRadius)
                            .stroke(
                                disabled ? disabledRatingBorderColor : enabledRatingBorderColor,
                                lineWidth: disabled ? disabledRatingBorderSize : enabledRatingBorderSize)
                    )
            }
        }
        .disabled(disabled)
    }
}
