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
    
    var textColor: Color {
        return Style.getColor(theme: Style.model?.rating?.text?.color) ?? Color(hex: "242729")
    }
    
    var textFontSize: CGFloat {
        return CGFloat(Style.model?.rating?.text?.textSize ?? 17)
    }
    
    
    // MARK: - BODY
    var body: some View {
        let enabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textEnabled?.color) ?? Color.white
        let disabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textDisabled?.color) ?? Color.white
        let enabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textEnabled?.textSize ?? 15)
        let disabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textDisabled?.textSize ?? 15)
        let enabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundEnabled) ?? Color(hex: "DD0A34")
        let disabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.backgroundDisabled) ?? Color(hex: "B7B7CA")
        
        TextEditor(text: $userInput)
            .frame(height: 100)
            .foregroundColor(textColor)
            .font(.system(size: textFontSize))
        
        
        Button {
            if userInput != "" {
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
        } label: {
            Text("Отправить")
                .foregroundColor(userInput == "" ? disabledRatingTextColor : enabledRatingTextColor)
                .font(.system(size: userInput == "" ? disabledRatingFontSize : enabledRatingFontSize))
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(userInput == "" ? disabledRatingBackgroundColor : enabledRatingBackgroundColor)
                .cornerRadius(8)
        }
        .disabled(userInput == "")
    }
}
