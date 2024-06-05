//
//  IQClientSession.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.05.2024.
//

import Foundation

struct IQClientSession: Decodable {
    var id: Int?
    var clientId: Int?
    var token: String?
    var integration: Bool?
    var integrationHash: String?
    var integrationCredentials: String?
}
