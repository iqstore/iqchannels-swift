//
//  Offer.swift
//  Pods
//
//  Created by Mikhail Zinkov on 05.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct OfferView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let questionAnswered: ((Bool) -> Void?)
    
    // MARK: - BODY
    var body: some View {
        let enabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.answerButton?.textEnabled?.color) ?? Color.white
        let disabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.answerButton?.textDisabled?.color) ?? Color.white
        let enabledRatingFontSize = CGFloat(Style.model?.rating?.answerButton?.textEnabled?.textSize ?? 15)
        let disabledRatingFontSize = CGFloat(Style.model?.rating?.answerButton?.textDisabled?.textSize ?? 15)
        let enabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.answerButton?.backgroundEnabled?.color) ?? Color(hex: "DD0A34")
        let disabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.answerButton?.backgroundDisabled?.color) ?? Color(hex: "B7B7CA")
        
        let enabledRatingIsBold = Style.model?.rating?.answerButton?.textEnabled?.textStyle?.bold ?? false
        let disabledRatingIsBold = Style.model?.rating?.answerButton?.textDisabled?.textStyle?.bold ?? false
        let enabledRatingIsItalic = Style.model?.rating?.answerButton?.textEnabled?.textStyle?.italic ?? false
        let disabledRatingIsItalic = Style.model?.rating?.answerButton?.textDisabled?.textStyle?.italic ?? false
        let enabledRatingAlignment = stringToAlignment(stringAlignment: Style.model?.rating?.answerButton?.textEnabled?.textAlign) ?? .center
        let disabledRatingAlignment = stringToAlignment(stringAlignment: Style.model?.rating?.answerButton?.textDisabled?.textAlign) ?? .center
        
        let enabledRatingRadius = Style.model?.rating?.answerButton?.backgroundEnabled?.border?.borderRadius ?? 8
        let disabledRatingRadius = Style.model?.rating?.answerButton?.backgroundDisabled?.border?.borderRadius ?? 8
        let enabledRatingBorderSize = Style.model?.rating?.answerButton?.backgroundEnabled?.border?.size ?? 0
        let disabledRatingBorderSize = Style.model?.rating?.answerButton?.backgroundDisabled?.border?.size ?? 0
        let enabledRatingBorderColor = Style.getColor(theme: Style.model?.rating?.answerButton?.backgroundEnabled?.border?.color) ?? Color(hex: "000000")
        let disabledRatingBorderColor = Style.getColor(theme: Style.model?.rating?.answerButton?.backgroundDisabled?.border?.color) ?? Color(hex: "000000")
        
        
        HStack() {
            Button {
                questionAnswered(false)
            } label: {
                if #available(iOS 16.0, *) {
                    Text("Нет")
                        .foregroundColor(disabledRatingTextColor)
                        .font(.system(size: disabledRatingFontSize))
                        .bold(disabledRatingIsBold)
                        .italic(disabledRatingIsItalic)
                        .multilineTextAlignment(disabledRatingAlignment)
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
                    Text("Нет")
                        .foregroundColor(disabledRatingTextColor)
                        .font(.system(size: disabledRatingFontSize))
                        .multilineTextAlignment(disabledRatingAlignment)
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

            Spacer()

            Button {
                questionAnswered(true)
            } label: {
                if #available(iOS 16.0, *) {
                    Text("Да")
                        .foregroundColor(enabledRatingTextColor)
                        .font(.system(size: enabledRatingFontSize))
                        .bold(enabledRatingIsBold)
                        .italic(enabledRatingIsItalic)
                        .multilineTextAlignment(enabledRatingAlignment)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(enabledRatingBackgroundColor)
                        .cornerRadius(enabledRatingRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: enabledRatingRadius)
                                .stroke(
                                    enabledRatingBorderColor,
                                    lineWidth: enabledRatingBorderSize)
                        )
                } else {
                    Text("Да")
                        .foregroundColor(enabledRatingTextColor)
                        .font(.system(size: enabledRatingFontSize))
                        .multilineTextAlignment(enabledRatingAlignment)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(enabledRatingBackgroundColor)
                        .cornerRadius(enabledRatingRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: enabledRatingRadius)
                                .stroke(
                                    enabledRatingBorderColor,
                                    lineWidth: enabledRatingBorderSize)
                        )
                }
            }
        }
    }
}
