//
//  IQRating.swift
//  Pods
//
//  Created by Muhammed Aralbek on 25.05.2024.
//  
//

import Foundation

struct IQRating: Codable, Equatable {
    var id: Int = 0
    var projectID: Int?
    var ticketID: Int?
    var clientID: Int?
    var ratingPollID: Int?
    var value: Int?
    var state: IQRatingState?
    var ratingPoll: IQRatingPoll?
}

enum IQRatingState: String, Codable {
    case invalid = ""
    case pending
    case ignored
    case rated
    case poll
    case finished
    
    init(from decoder: any Decoder) throws {
        self = try IQRatingState(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .invalid
    }
}
