//
//  IQKey.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 11.05.2024.
//

import Foundation

struct IQKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}
