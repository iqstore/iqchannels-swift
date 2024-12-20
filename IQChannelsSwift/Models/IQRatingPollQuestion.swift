//
//  IQRatingPollQuestion.swift
//  Pods
//
//  Created by Mikhail Zinkov on 19.11.2024.
//

import Foundation

struct IQRatingPollQuestion: Codable, Equatable {
    var id: Int = 0
    var asTicketRating: Bool = false
    var text: String = ""
    var type: IQRatingQuestionType
    var scale: IQRatingQuestionScale?
    var answers: [IQRatingQuestionAnswer]?
}


enum IQRatingQuestionType: String, Codable {
    case invalid = ""
    case oneOfList = "one_of_list"
    case input
    case stars
    case fcr
    case scale
    
    init(from decoder: any Decoder) throws {
        self = try IQRatingQuestionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .invalid
    }
}

struct IQRatingQuestionScale: Codable, Equatable {
    var fromValue: Int = 0
    var toValue: Int = 0
    var items: [String: String]?
}

struct IQRatingQuestionAnswer: Codable, Equatable, Identifiable {
    var id: Int = 0
    var text: String = ""
    var fcr: Bool?
}
