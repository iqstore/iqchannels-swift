import Foundation

struct IQChatItemModel: Identifiable, Equatable {
    let id: String = UUID().uuidString
    
    let channel: String
    let info: IQMultiChatsInfo?
    let chatType: IQChatType
    
    enum CodingKeys: String, CodingKey {
        case channel, info, chatType
    }
}
