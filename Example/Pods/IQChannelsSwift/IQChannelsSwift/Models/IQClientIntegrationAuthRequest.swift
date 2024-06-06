//
//  IQClientIntegrationAuthRequest.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 11.05.2024.
//

import Foundation

struct IQClientIntegrationAuthRequest: Encodable {
    let credentials: String
    let channel: String
}

