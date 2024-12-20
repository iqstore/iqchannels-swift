//
//  Stars.swift
//  Pods
//
//  Created by Mikhail Zinkov on 05.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct StarsView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let rating: IQRating
    let ratingPoll: IQRatingPoll
    let currentQuestionIndex: Int
    let starWidth: CGFloat
    let questionAnswered: ((IQRatingPollClientAnswerInput) -> Void?)
    
    @State private var selectedRating: Int? = nil
    
    var ratingPollQuestionId: Int {
        return ratingPoll.questions?[currentQuestionIndex].id ?? 0
    }
    
    var asTicketRating: Bool {
        return ratingPoll.questions?[currentQuestionIndex].asTicketRating ?? false
    }
    
    
    // MARK: - BODY
    var body: some View {
        let enabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textEnabled?.color) ?? Color.white
        let disabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textDisabled?.color) ?? Color.white
        let enabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textEnabled?.textSize ?? 15)
        let disabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textDisabled?.textSize ?? 15)
        let enabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.colorEnabled) ?? Color(hex: "DD0A34")
        let disabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.colorDisabled) ?? Color(hex: "B7B7CA")
        
        HStack(spacing: 10) {
            ForEach(1..<6) { i in
                Button {
                    selectedRating = i
                } label: {
                    if i <= selectedRating ?? 0 {
                        if let fullStarUrl = Style.model?.rating?.fullStar {
                            AnimatedImage(url: fullStarUrl)
                                .resizable()
                                .indicator(SDWebImageActivityIndicator.gray)
                                .transition(SDWebImageTransition.fade)
                                .scaledToFit()
                                .frame(width: starWidth, height: starWidth)
                        } else {
                            Image(name: "star_on")
                                .resizable()
                                .scaledToFit()
                                .frame(width: starWidth, height: starWidth)
                        }
                    } else {
                        if let emptyStarUrl = Style.model?.rating?.emptyStar {
                            AnimatedImage(url: emptyStarUrl)
                                .resizable()
                                .indicator(SDWebImageActivityIndicator.gray)
                                .transition(SDWebImageTransition.fade)
                                .scaledToFit()
                                .frame(width: starWidth, height: starWidth)
                        } else {
                            Image(name: "star_off")
                                .resizable()
                                .scaledToFit()
                                .frame(width: starWidth, height: starWidth)
                        }
                    }
                }
            }
        }

        Button {
            if let selectedRating {
                questionAnswered(IQRatingPollClientAnswerInput(projectId: rating.projectID ?? 0,
                                                               clientId: rating.clientID ?? 0,
                                                               ratingId: rating.id,
                                                               ratingPollQuestionId: ratingPollQuestionId,
                                                               type: .stars,
                                                               fcr: nil,
                                                               ratingPollAnswerId: nil,
                                                               answerInput: nil,
                                                               answerStars: selectedRating,
                                                               answerScale: nil,
                                                               asTicketRating: asTicketRating))
            }
        } label: {
            Text("Отправить")
                .foregroundColor(selectedRating == nil ? disabledRatingTextColor : enabledRatingTextColor)
                .font(.system(size: selectedRating == nil ? disabledRatingFontSize : enabledRatingFontSize))
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(selectedRating == nil ? disabledRatingBackgroundColor : enabledRatingBackgroundColor)
                .cornerRadius(8)
        }
        .disabled(selectedRating == nil)
    }
}







