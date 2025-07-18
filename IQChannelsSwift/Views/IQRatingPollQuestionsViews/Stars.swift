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
    let questionAnswered: ((IQRatingPollClientAnswerInput) -> Void)
    
    @State private var selectedRating: Int? = nil
    
    var ratingPollQuestionId: Int {
        return ratingPoll.questions?[currentQuestionIndex].id ?? 0
    }
    
    var asTicketRating: Bool {
        return ratingPoll.questions?[currentQuestionIndex].asTicketRating ?? false
    }
    
    
    // MARK: - BODY
    var body: some View {
        HStack(spacing: 10) {
            ForEach(1..<6) { i in
                Button {
                    selectedRating = i
                } label: {
                    if i <= selectedRating ?? 0 {
                        if let fullStarUrl = IQStyle.model?.rating?.fullStar {
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
                        if let emptyStarUrl = IQStyle.model?.rating?.emptyStar {
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
        
        SentRatingButton(disabled: selectedRating == nil) {
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
    }
}







