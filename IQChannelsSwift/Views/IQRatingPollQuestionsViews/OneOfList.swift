//
//  OneOfList.swift
//  Pods
//
//  Created by Mikhail Zinkov on 05.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct OneOfListView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let rating: IQRating
    let ratingPoll: IQRatingPoll
    let currentQuestionIndex: Int
    let questionAnswered: ((IQRatingPollClientAnswerInput) -> Void?)
    
    var ratingPollQuestionId: Int {
        return ratingPoll.questions?[currentQuestionIndex].id ?? 0
    }
    
    var answers: [IQRatingQuestionAnswer] {
        return ratingPoll.questions?[currentQuestionIndex].answers ?? []
    }
    
    
    // MARK: - BODY
    var body: some View {
        let disabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.answerButton?.textDisabled?.color) ?? Color.white
        let disabledRatingFontSize = CGFloat(Style.model?.rating?.answerButton?.textDisabled?.textSize ?? 15)
        let disabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.answerButton?.backgroundDisabled?.color) ?? Color(hex: "B7B7CA")
        
        let disabledRatingIsBold = Style.model?.rating?.answerButton?.textDisabled?.textStyle?.bold ?? false
        let disabledRatingIsItalic = Style.model?.rating?.answerButton?.textDisabled?.textStyle?.italic ?? false
        let disabledRatingAlignment = stringToAlignment(stringAlignment: Style.model?.rating?.answerButton?.textDisabled?.textAlign) ?? .center
        
        let disabledRatingRadius = Style.model?.rating?.answerButton?.backgroundDisabled?.border?.borderRadius ?? 8
        let disabledRatingBorderSize = Style.model?.rating?.answerButton?.backgroundDisabled?.border?.size ?? 0
        let disabledRatingBorderColor = Style.getColor(theme: Style.model?.rating?.answerButton?.backgroundDisabled?.border?.color) ?? Color(hex: "000000")
        
        VStack() {
            ForEach(answers) { answer in
                Button {
                    questionAnswered(IQRatingPollClientAnswerInput(projectId: rating.projectID ?? 0,
                                                                   clientId: rating.clientID ?? 0,
                                                                   ratingId: rating.id,
                                                                   ratingPollQuestionId: ratingPollQuestionId,
                                                                   type: .oneOfList,
                                                                   fcr: nil,
                                                                   ratingPollAnswerId: answer.id,
                                                                   answerInput: nil,
                                                                   answerStars: nil,
                                                                   answerScale: nil,
                                                                   asTicketRating: nil))
                } label: {
                    if #available(iOS 16.0, *) {
                        Text(answer.text)
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
                        Text(answer.text)
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
            }
        }
    }
}
