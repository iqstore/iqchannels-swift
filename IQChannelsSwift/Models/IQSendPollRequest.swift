//
//  IQSendPollRequest.swift
//  Pods
//
//  Created by Mikhail Zinkov on 12.12.2024.
//


import Foundation

struct IQSendPollRequest: Encodable {
    let ratingPollClientAnswerInput: [IQRatingPollClientAnswerInput]
}
