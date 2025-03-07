//
//  Input.swift
//  Pods
//
//  Created by Mikhail Zinkov on 05.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct InputView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let rating: IQRating
    let ratingPoll: IQRatingPoll
    let currentQuestionIndex: Int
    let questionAnswered: ((IQRatingPollClientAnswerInput) -> Void?)
    
    @State private var userInput: String = ""
    
    var ratingPollQuestionId: Int {
        return ratingPoll.questions?[currentQuestionIndex].id ?? 0
    }
    
    var backgroundColor: Color {
        return Style.getColor(theme: Style.model?.rating?.inputBackground?.color) ?? Color(hex: "ffffff")
    }
    var backgroundRadius: CGFloat {
        return Style.model?.rating?.inputBackground?.border?.borderRadius ?? 12
    }
    var backgroundBorderSize: CGFloat {
        return Style.model?.rating?.inputBackground?.border?.size ?? 0
    }
    var backgroundBorderColor: Color {
        return Style.getColor(theme: Style.model?.rating?.inputBackground?.border?.color) ?? Color(hex: "000000")
    }
    
    
    
    var textColor: Color {
        return Style.getColor(theme: Style.model?.rating?.inputText?.color) ?? Color(hex: "242729")
    }
    
    var textFontSize: CGFloat {
        return CGFloat(Style.model?.rating?.inputText?.textSize ?? 17)
    }
    
    
    // MARK: - BODY
    var body: some View {
        let enabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textEnabled?.color) ?? Color.white
        let disabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textDisabled?.color) ?? Color.white
        let enabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textEnabled?.textSize ?? 15)
        let disabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textDisabled?.textSize ?? 15)
        let enabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundEnabled?.color) ?? Color(hex: "DD0A34")
        let disabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundDisabled?.color) ?? Color(hex: "B7B7CA")
        
        
        let enabledRatingRadius = Style.model?.rating?.sentRating?.backgroundEnabled?.border?.borderRadius ?? 8
        let disabledRatingRadius = Style.model?.rating?.sentRating?.backgroundDisabled?.border?.borderRadius ?? 8
        let enabledRatingBorderSize = Style.model?.rating?.sentRating?.backgroundEnabled?.border?.size ?? 0
        let disabledRatingBorderSize = Style.model?.rating?.sentRating?.backgroundDisabled?.border?.size ?? 0
        let enabledRatingBorderColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundEnabled?.border?.color) ?? Color(hex: "000000")
        let disabledRatingBorderColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundDisabled?.border?.color) ?? Color(hex: "000000")
        
        let cursorColor = Style.getColor(theme: Style.model?.toolsToMessage?.cursorColor) ?? Color(hex: "525252")
        
        if #available(iOS 16.0, *) {
            TextEditor(text: $userInput)
                .frame(height: 100)
                .foregroundColor(textColor)
                .scrollContentBackground(.hidden)
                .background(backgroundColor)
                .font(.system(size: textFontSize))
                .cornerRadius(backgroundRadius)
                .tint(cursorColor)
                .overlay(
                    RoundedRectangle(cornerRadius: backgroundRadius)
                        .stroke(backgroundBorderColor, lineWidth: backgroundBorderSize)
                )
        } else {
            TextEditor(text: $userInput)
                .frame(height: 100)
                .foregroundColor(textColor)
                .background(backgroundColor)
                .font(.system(size: textFontSize))
                .cornerRadius(backgroundRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: backgroundRadius)
                        .stroke(backgroundBorderColor, lineWidth: backgroundBorderSize)
                )
        }
        
        SentRatingButton(disabled: userInput == "") {
            questionAnswered(IQRatingPollClientAnswerInput(projectId: rating.projectID ?? 0,
                                                           clientId: rating.clientID ?? 0,
                                                           ratingId: rating.id,
                                                           ratingPollQuestionId: ratingPollQuestionId,
                                                           type: .input,
                                                           fcr: nil,
                                                           ratingPollAnswerId: nil,
                                                           answerInput: userInput,
                                                           answerStars: nil,
                                                           answerScale: nil,
                                                           asTicketRating: nil))
        }
    }
}
