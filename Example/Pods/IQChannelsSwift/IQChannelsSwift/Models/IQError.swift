//
//  IQError.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.05.2024.
//

import Foundation

struct IQError: Decodable {
    var code: IQErrorCode?
    var text: String?
}
