//
//  IQActorType.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 20.05.2024.
//

import Foundation

enum IQAuthorType: String, Codable, Equatable{
    case anonymous
    case client
    case user
    case system

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = (try? container.decode(String.self)) ?? ""

            self = IQAuthorType(rawValue: value) ?? .system
        }
}
