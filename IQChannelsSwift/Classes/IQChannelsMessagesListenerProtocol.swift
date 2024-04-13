import Foundation

protocol IQChannelsMessagesListenerProtocol: AnyObject {
    var id: String { get }
    func iq(messages: [IQChatMessage], moreMessages: Bool)
    func iqMessagesCleared()
    func iq(messagesError error: Error)
    func iq(messageAdded message: IQChatMessage)
    func iq(messageSent message: IQChatMessage)
    func iq(messageUpdated message: IQChatMessage)
    func iq(messageTyping user: IQUser?)
    func iq(messagesRemoved messages: [IQChatMessage])
}
