//
//  IQMessageForm.swift
//  Pods
//
//  Created by Muhammed Aralbek on 12.05.2024.
//  
//

import Foundation

struct IQMessageForm: Encodable {
    
    var localId: Int?
    var payload: IQMessagePayloadType?
    var text: String?
    var fileId: String?
    var replyToMessageID: Int?
    var botpressPayload: String?
    var chatType: IQChatType?
    
    init(_ message: IQMessage) {
        localId = message.localID
        payload = message.payload
        text = message.text ?? ""
        fileId = message.fileID
        replyToMessageID = message.replyToMessageID
        botpressPayload = message.botpressPayload
        chatType = message.chatType
    }

}
