import Foundation

class IQRelations {
    
    var channels: [IQChannel] = []
    var chats: [IQChat] = []
    var chatMessages: [IQChatMessage] = []
    var clients: [IQClient] = []
    var files: [IQFile] = []
    var ratings: [IQRating] = []
    var users: [IQUser] = []
}

extension IQRelations {
    
    static func fromJSONObject(_ object: Any?) -> IQRelations? {
        guard let jsonObject = object as? [String: Any] else { return nil }
        
        var rels = IQRelations()
        rels.channels = IQChannel.fromJSONArray(jsonObject["Channels"])
        rels.chats = IQChat.fromJSONArray(jsonObject["Chats"])
        rels.chatMessages = IQChatMessage.fromJSONArray(jsonObject["ChatMessages"])
        rels.clients = IQClient.fromJSONArray(jsonObject["Clients"])
        rels.files = IQFile.fromJSONArray(jsonObject["Files"])
        rels.ratings = IQRating.fromJSONArray(jsonObject["Ratings"])
        rels.users = IQUser.fromJSONArray(jsonObject["Users"])
        
        return rels
    }
}
