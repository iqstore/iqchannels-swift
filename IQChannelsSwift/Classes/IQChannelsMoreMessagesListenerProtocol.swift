import Foundation

protocol IQChannelsMoreMessagesListenerProtocol: AnyObject {
    var id: String { get }
    func iqMoreMessagesLoaded()
    func iqMoreMessagesError(_ error: Error)
}
