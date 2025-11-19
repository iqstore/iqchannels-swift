//
//  FCR.swift
//  Pods
//
//  Created by Mikhail Zinkov on 05.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct FCRView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let rating: IQRating
    let ratingPoll: IQRatingPoll
    let currentQuestionIndex: Int
    let questionAnswered: ((IQRatingPollClientAnswerInput) -> Void)
    
    var ratingPollQuestionId: Int {
        return ratingPoll.questions?[currentQuestionIndex].id ?? 0
    }
    
    var answers: [IQRatingQuestionAnswer] {
        return ratingPoll.questions?[currentQuestionIndex].answers ?? []
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
        
        HStack() {
            ForEach(answers) { answer in
                Button {
                    questionAnswered(IQRatingPollClientAnswerInput(projectId: rating.projectID ?? 0,
                                                                   clientId: rating.clientID ?? 0,
                                                                   ratingId: rating.id,
                                                                   ratingPollQuestionId: ratingPollQuestionId,
                                                                   type: .fcr,
                                                                   fcr: answer.fcr,
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
                            .frame(maxWidth: .infinity, alignment: textAlignmentToAlignment(textAlignment: disabledRatingAlignment) ?? .center)
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
                            .frame(maxWidth: .infinity, alignment: textAlignmentToAlignment(textAlignment: disabledRatingAlignment) ?? .center)
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
