import Foundation

protocol IQChannelsUnreadListenerProtocol: AnyObject {
    var id: String { get }
    func iqUnreadChanged(_ unread: Int)
}
