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
        let enabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textEnabled?.color) ?? Color.white
        let disabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textDisabled?.color) ?? Color.white
        let enabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textEnabled?.textSize ?? 15)
        let disabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textDisabled?.textSize ?? 15)
        
        
        let enabledRatingIsBold = Style.model?.rating?.sentRating?.textEnabled?.textStyle?.bold ?? false
        let disabledRatingIsBold = Style.model?.rating?.sentRating?.textDisabled?.textStyle?.bold ?? false
        let enabledRatingIsItalic = Style.model?.rating?.sentRating?.textEnabled?.textStyle?.italic ?? false
        let disabledRatingIsItalic = Style.model?.rating?.sentRating?.textDisabled?.textStyle?.italic ?? false
        let enabledRatingAlignment = stringToAlignment(stringAlignment: Style.model?.rating?.sentRating?.textEnabled?.textAlign) ?? .center
        let disabledRatingAlignment = stringToAlignment(stringAlignment: Style.model?.rating?.sentRating?.textDisabled?.textAlign) ?? .center
        
        
        let enabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundEnabled?.color) ?? Color(hex: "DD0A34")
        let disabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundDisabled?.color) ?? Color(hex: "B7B7CA")
        let enabledRatingRadius = Style.model?.rating?.sentRating?.backgroundEnabled?.border?.borderRadius ?? 8
        let disabledRatingRadius = Style.model?.rating?.sentRating?.backgroundDisabled?.border?.borderRadius ?? 8
        let enabledRatingBorderSize = Style.model?.rating?.sentRating?.backgroundEnabled?.border?.size ?? 0
        let disabledRatingBorderSize = Style.model?.rating?.sentRating?.backgroundDisabled?.border?.size ?? 0
        let enabledRatingBorderColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundEnabled?.border?.color) ?? Color(hex: "000000")
        let disabledRatingBorderColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundDisabled?.border?.color) ?? Color(hex: "000000")
        
        
        Button {
            if(!disabled){
                action()
            }
        } label: {
            if #available(iOS 16.0, *) {
                Text("Отправить")
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
                Text("Отправить")
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
