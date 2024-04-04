import Foundation

protocol IQChannelsMessagesListener: AnyObject {
    var id: String { get }
    func iq(messages: [IQChatMessage])
    func iqMessagesCleared()
    func iq(messagesError error: Error)
    func iq(messageAdded message: IQChatMessage)
    func iq(messageSent message: IQChatMessage)
    func iq(messageUpdated message: IQChatMessage)
    func iq(messageTyping user: IQUser?)
    func iq(messagesRemoved messages: [IQChatMessage])
}
