import Foundation

class IQChatMessageForm: IQJSONEncodable {
    
    var localId: Int = 0
    var payload: IQChatPayloadType?
    var text: String?
    var fileId: String?
    var replyToMessageID: Int?
    var botpressPayload: String?
    
    init(message: IQChatMessage?) {
        localId = message?.localId ?? 0
        payload = message?.payload
        text = message?.text ?? ""
        fileId = message?.fileId
        replyToMessageID = message?.replyToMessageID
        botpressPayload = message?.botpressPayload
    }
    
    func toJSONObject() -> [String: Any] {
        var dict = [String: Any]()
        dict["LocalId"] = localId
        if payload != nil {
            if let payload {
                dict["Payload"] = payload.rawValue
            }
        }
        if let text {
            dict["Text"] = text
        }
        if let replyToMessageID {
            dict["ReplyToMessageId"] = replyToMessageID
        }
        if let fileId {
            dict["FileId"] = fileId
        }
        if let botpressPayload {
            dict["BotpressPayload"] = botpressPayload
        }
        return dict
    }
}
