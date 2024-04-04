import Foundation

protocol IQChannelsUnreadListener: AnyObject {
    var id: String { get }
    func iqUnreadChanged(_ unread: Int)
}
