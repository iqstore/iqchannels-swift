//
//  IQRelationMap.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.05.2024.
//

import Foundation

struct IQRelationMap {
    
    var channels: [Int: IQChannel] = [:]
    var chats: [Int: IQChat] = [:]
    var chatMessages: [Int: IQMessage] = [:]
    var clients: [Int: IQClient] = [:]
    var files: [String: IQFile] = [:]
    var ratings: [Int: IQRating] = [:]
    var ratingPolls: [Int: IQRatingPoll] = [:]
    var users: [Int: IQUser] = [:]
    
    init() {
        
    }
    
    init(client: IQClient) {
        clients[client.id] = client
    }
    
    init(relations: IQRelations?) {        
        if let channels = relations?.channels {
            for channel in channels {
                self.channels[channel.id] = channel
            }
        }
        
        if let chats = relations?.chats {
            for chat in chats {
                self.chats[chat.id] = chat
            }
        }
        
        if let chatMessages = relations?.chatMessages {
            for message in chatMessages {
                self.chatMessages[message.messageID] = message
            }
        }
        
        if let clients = relations?.clients {
            for client in clients {
                self.clients[client.id] = client
            }
        }
        
        if let files = relations?.files {
            for file in files {
                if let fileId = file.id {
                    self.files[fileId] = file
                }
            }
        }
        
        if var ratings = relations?.ratings {
            for i in 0..<ratings.count {
                ratings[i].ratingPoll = relations?.ratingPolls?.last
                self.ratings[ratings[i].id] = ratings[i]
            }
        }
        
        if let users = relations?.users {
            for user in users {
                self.users[user.id] = user
            }
        }
    }
}
