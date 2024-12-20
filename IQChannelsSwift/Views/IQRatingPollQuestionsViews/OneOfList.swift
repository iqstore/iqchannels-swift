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
        let disabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textDisabled?.color) ?? Color.white
        let disabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textDisabled?.textSize ?? 15)
        let disabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.colorDisabled) ?? Color(hex: "B7B7CA")
        
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
                    Text(answer.text)
                        .foregroundColor(disabledRatingTextColor)
                        .font(.system(size: disabledRatingFontSize))
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(disabledRatingBackgroundColor)
                        .cornerRadius(8)
                }
            }
        }
    }
}
