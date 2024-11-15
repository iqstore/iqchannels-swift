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
    var state: IQRatingState?
    var value: Int?
}

enum IQRatingState: String, Codable {
    case invalid = ""
    case pending
    case ignored
    case rated
    
    init(from decoder: any Decoder) throws {
        self = try IQRatingState(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .invalid
    }
    
}
