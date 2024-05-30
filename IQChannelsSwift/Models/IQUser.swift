//
//  IQUser.swift
//  Pods
//
//  Created by Muhammed Aralbek on 14.05.2024.
//  
//

import Foundation

struct IQUser: Decodable, Equatable {
    var id: Int
    var displayName: String?
    var avatarID: String?
    
    var avatarURL: URL?
}
