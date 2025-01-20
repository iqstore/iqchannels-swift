//
//  IQClient.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.05.2024.
//

import Foundation

struct IQClient: Equatable, Codable {
    var id: Int = 0
    var name: String?
    var integrationId: String?
    var personalManagerID: Int?
    var personalManagerGroupID: Int?
    var multiChatsInfo: IQMultiChatsInfo?
    
    var canAccessPersonalManager: Bool {
        (personalManagerID != nil || personalManagerGroupID != nil) && (multiChatsInfo?.enableForPersonalManagers ?? false)
    }
    
    var chatTypes: [IQChatType] {
        guard let multiChatsInfo else { return [.chat] }
        
        if (multiChatsInfo.enableChat ?? false) && canAccessPersonalManager {
            return [.chat, .manager]
        }
        return (canAccessPersonalManager) ? [.manager] : [.chat]
    }
}
