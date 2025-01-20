//
//  Thanks.swift
//  Pods
//
//  Created by Mikhail Zinkov on 05.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ThanksView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let questionAnswered: ((Bool) -> Void?)
    
    // MARK: - BODY
    var body: some View {
        let enabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textEnabled?.color) ?? Color.white
        let disabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textDisabled?.color) ?? Color.white
        let enabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textEnabled?.textSize ?? 15)
        let disabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textDisabled?.textSize ?? 15)
        let enabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundEnabled) ?? Color(hex: "DD0A34")
        let disabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundDisabled) ?? Color(hex: "B7B7CA")
        
        HStack() {
            Button {
                questionAnswered(false)
            } label: {
                Text("Нет")
                    .foregroundColor(disabledRatingTextColor)
                    .font(.system(size: disabledRatingFontSize))
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(disabledRatingBackgroundColor)
                    .cornerRadius(8)
            }

            Spacer()

            Button {
                questionAnswered(true)
            } label: {
                Text("Да")
                    .foregroundColor(enabledRatingTextColor)
                    .font(.system(size: enabledRatingFontSize))
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(enabledRatingBackgroundColor)
                    .cornerRadius(8)
            }
        }
    }
}
