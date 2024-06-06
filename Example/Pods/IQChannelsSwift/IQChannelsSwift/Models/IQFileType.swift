//
//  IQFileType.swift
//  Pods
//
//  Created by Muhammed Aralbek on 20.05.2024.
//  
//

import Foundation

enum IQFileType: String, Codable, Equatable {
    case invalid = ""
    case file
    case image
    
    init(from decoder: any Decoder) throws {
        self = try IQFileType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .invalid
    }
}
