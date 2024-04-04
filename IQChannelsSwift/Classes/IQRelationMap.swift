import Foundation

class IQRelationMap {
    
    var channels: [Int: IQChannel]
    var chats: [Int: IQChat]
    var chatMessages: [Int: IQChatMessage]
    var clients: [Int: IQClient]
    var files: [String: IQFile]
    var ratings: [Int: IQRating]
    var users: [Int: IQUser]
    
    init() {
        channels = [:]
        chats = [:]
        chatMessages = [:]
        clients = [:]
        files = [:]
        ratings = [:]
        users = [:]
    }
    
    convenience init(client: IQClient) {
        self.init()
        clients[client.id] = client
    }
    
    convenience init(relations: IQRelations?) {
        self.init()
        
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
                self.chatMessages[message.id] = message
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
        
        if let ratings = relations?.ratings {
            for rating in ratings {
                self.ratings[rating.id] = rating
            }
        }
        
        if let users = relations?.users {
            for user in users {
                self.users[user.id] = user
            }
        }
    }
}
