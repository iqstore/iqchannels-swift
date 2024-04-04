import MessageKit

struct MessageSender: MessageKit.SenderType {
    var senderId: String
    var displayName: String
}

struct MessageMediaItem: MessageKit.MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
}
