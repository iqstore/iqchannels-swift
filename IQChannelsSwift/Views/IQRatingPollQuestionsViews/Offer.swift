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
    
    let questionAnswered: ((Bool) -> Void)
    
    // MARK: - BODY
    var body: some View {
        let enabledRatingTextColor = IQStyle.getColor(theme: IQStyle.model?.rating?.answerButton?.textEnabled?.color) ?? Color.white
        let disabledRatingTextColor = IQStyle.getColor(theme: IQStyle.model?.rating?.answerButton?.textDisabled?.color) ?? Color.white
        let enabledRatingFontSize = CGFloat(IQStyle.model?.rating?.answerButton?.textEnabled?.textSize ?? 15)
        let disabledRatingFontSize = CGFloat(IQStyle.model?.rating?.answerButton?.textDisabled?.textSize ?? 15)
        let enabledRatingBackgroundColor = IQStyle.getColor(theme: IQStyle.model?.rating?.answerButton?.backgroundEnabled?.color) ?? Color(hex: "DD0A34")
        let disabledRatingBackgroundColor = IQStyle.getColor(theme: IQStyle.model?.rating?.answerButton?.backgroundDisabled?.color) ?? Color(hex: "B7B7CA")
        
        let enabledRatingIsBold = IQStyle.model?.rating?.answerButton?.textEnabled?.textStyle?.bold ?? false
        let disabledRatingIsBold = IQStyle.model?.rating?.answerButton?.textDisabled?.textStyle?.bold ?? false
        let enabledRatingIsItalic = IQStyle.model?.rating?.answerButton?.textEnabled?.textStyle?.italic ?? false
        let disabledRatingIsItalic = IQStyle.model?.rating?.answerButton?.textDisabled?.textStyle?.italic ?? false
        let enabledRatingAlignment = stringToAlignment(stringAlignment: IQStyle.model?.rating?.answerButton?.textEnabled?.textAlign) ?? .center
        let disabledRatingAlignment = stringToAlignment(stringAlignment: IQStyle.model?.rating?.answerButton?.textDisabled?.textAlign) ?? .center
        
        let enabledRatingRadius = IQStyle.model?.rating?.answerButton?.backgroundEnabled?.border?.borderRadius ?? 8
        let disabledRatingRadius = IQStyle.model?.rating?.answerButton?.backgroundDisabled?.border?.borderRadius ?? 8
        let enabledRatingBorderSize = IQStyle.model?.rating?.answerButton?.backgroundEnabled?.border?.size ?? 0
        let disabledRatingBorderSize = IQStyle.model?.rating?.answerButton?.backgroundDisabled?.border?.size ?? 0
        let enabledRatingBorderColor = IQStyle.getColor(theme: IQStyle.model?.rating?.answerButton?.backgroundEnabled?.border?.color) ?? Color(hex: "000000")
        let disabledRatingBorderColor = IQStyle.getColor(theme: IQStyle.model?.rating?.answerButton?.backgroundDisabled?.border?.color) ?? Color(hex: "000000")
        
        
        HStack() {
            Button {
                questionAnswered(false)
            } label: {
                if #available(iOS 16.0, *) {
                    Text(IQLanguageTexts.model.ratingOfferNo ?? "Нет")
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
                    Text(IQLanguageTexts.model.ratingOfferNo ?? "Нет")
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
                    Text(IQLanguageTexts.model.ratingOfferYes ?? "Да")
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
                    Text(IQLanguageTexts.model.ratingOfferYes ?? "Да")
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
