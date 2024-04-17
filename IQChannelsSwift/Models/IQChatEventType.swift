import Foundation

public enum IQChatEventType: String {
    case invalid = ""
    case chatCreated = "chat_created"
    case chatOpened = "chat_opened"
    case chatClosed = "chat_closed"
    case typing
    case messageCreated = "message_created"
    case systemMessageCreated = "system_message_created"
    case messageReceived = "message_received"
    case messageRead = "message_read"
    case deleteMessages = "delete-messages"
}
