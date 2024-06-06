//
//  IQSingleChoice.swift
//  Pods
//
//  Created by Muhammed Aralbek on 22.05.2024.
//  
//

import Foundation

struct IQSingleChoice: Codable, Equatable, Identifiable, Hashable {
    var id: Int = 0
    var chatMessageID: Int = 0
    var clientID: Int = 0
    var deleted: Bool = false
    
    var title: String?
    var value: String?
    var tag: String?
}
