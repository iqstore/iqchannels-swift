//
//  IQChat.swift
//  Pods
//
//  Created by Muhammed Aralbek on 14.05.2024.
//  
//

import Foundation

struct IQChat: Decodable {
    var id: Int
    var clientID: Int
    var channelID: Int
    
    var client: IQClient?
    var channel: IQChannel?
}
