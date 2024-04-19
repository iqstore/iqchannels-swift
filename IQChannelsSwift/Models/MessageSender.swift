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
    
    mutating func setAppropriateSizeForImage() {
        let maxWidth = CGFloat(210)
        let maxHeight = CGFloat(150)
        let minWidth = CGFloat(100)
        guard let image = image else {
            size = .init(width: maxWidth, height: maxHeight)
            return
        }
        
        if image.size.width > image.size.height {
            let height = maxWidth * image.size.height / image.size.width
            self.size = .init(width: maxWidth, height: height)
        } else {
            let width = maxHeight * image.size.width / image.size.height
            self.size = .init(width: max(width, minWidth), height: maxHeight)
        }
    }
    
}
