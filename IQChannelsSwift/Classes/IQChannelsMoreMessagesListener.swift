import Foundation

protocol IQChannelsMoreMessagesListener: AnyObject {
    var id: String { get }
    func iqMoreMessagesLoaded()
    func iqMoreMessagesError(_ error: Error)
}
