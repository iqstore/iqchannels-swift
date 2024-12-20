//
//  IQRatingPoll.swift
//  Pods
//
//  Created by Mikhail Zinkov on 19.11.2024.
//

import Foundation

struct IQRatingPoll: Codable, Equatable {
    var id: Int = 0
    var feedbackThanks: Bool = false
    var feedbackThanksText: String = ""
    var showOffer: Bool = false
    var questions: [IQRatingPollQuestion]?
}
