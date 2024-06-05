import UIKit

struct MessageControlInfo {
    let message: IQMessage
    let replyMessage: IQMessage?
    let frame: CGRect
    let controlActions: [MessageControlType] = [.copy, .reply]
    var currentSnapshot: UIImage?
}
