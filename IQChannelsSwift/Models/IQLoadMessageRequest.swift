//
//  IQMaxIdQuery.swift
//  Pods
//
//  Created by Muhammed Aralbek on 18.05.2024.
//  
//

import Foundation

struct IQLoadMessageRequest: Encodable {
    var maxID: Int?
    var limit: Int?
    var clientId: Int?
    let chatType: IQChatType
}
