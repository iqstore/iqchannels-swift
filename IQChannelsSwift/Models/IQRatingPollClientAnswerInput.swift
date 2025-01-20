//
//  IQRatingPollClientAnswerInput.swift
//  Pods
//
//  Created by Mikhail Zinkov on 12.12.2024.
//

import Foundation

struct IQRatingPollClientAnswerInput: Codable, Equatable {
    var projectId: Int = 0
    var clientId: Int = 0
    var ratingId: Int = 0
    var ratingPollQuestionId: Int = 0
    var type: IQRatingQuestionType = IQRatingQuestionType.fcr
    var fcr: Bool? = nil
    var ratingPollAnswerId: Int? = nil
    var answerInput: String? = nil
    var answerStars: Int? = nil
    var answerScale: Int? = nil
    var asTicketRating: Bool? = nil
}
