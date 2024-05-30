import SwiftUI
import SDWebImageSwiftUI

struct MessageReplyView: View {
    
    // MARK: - PROPERTIES
    let message: IQMessage
    let isMy: Bool
    let onReplyMessageTapCompletion: ((Int) -> Void)?
    
    // MARK: - BODY
    var body: some View {
        Button {
            onReplyMessageTapCompletion?(message.messageID)
        } label: {
            HStack(spacing: 8) {
                let tintColor = isMy ? Color.white : Color(hex: "DD0A34")
                Capsule()
                    .fill(tintColor)
                    .frame(width: 2, height: 32)
                
                if message.payload == .file,
                   message.file?.type == .image {
                    AnimatedImage(url: message.file?.imagePreviewUrl)
                        .resizable()
                        .indicator(SDWebImageActivityIndicator.gray)
                        .transition(SDWebImageTransition.fade)
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .cornerRadius(2)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    let senderColor = isMy ? Color.white : Color(hex: "242729")
                    Text(message.senderName)
                        .font(.system(size: 13))
                        .foregroundColor(senderColor)
                        .lineLimit(1)
                    
                    Text(message.messageText)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "919399"))
                        .lineLimit(1)
                }
            }
            .frame(height: 34)
        }
    }
}
