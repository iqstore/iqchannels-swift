//
//  IQMessagePayloadType.swift
//  Pods
//
//  Created by Muhammed Aralbek on 12.05.2024.
//  
//

import Foundation

enum IQMessagePayloadType: String, Codable, Equatable {
    case invalid = ""
    case text
    case file
    case singleChoice = "single-choice"
    case card
    case carousel
    
    init(from decoder: any Decoder) throws {
        self = try IQMessagePayloadType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .invalid
    }

}
