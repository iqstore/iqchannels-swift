//
//  IQAction.swift
//  Pods
//
//  Created by Muhammed Aralbek on 25.05.2024.
//  
//

import Foundation

struct IQAction: Codable, Equatable, Identifiable {
    var id: Int
    var chatMessageID: Int
    var clientID: Int
    var title: String?
    var action: String?
    var payload: String?
    var url: String?
}
