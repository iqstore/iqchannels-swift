import SwiftUI
import SDWebImageSwiftUI

struct MessageReplyView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let message: IQMessage
    let isMy: Bool
    let onReplyMessageTapCompletion: ((Int) -> Void)?
    
    var textColor: Color {
        let clientColor = Style.getColor(theme: Style.model?.messages?.replyTextClient?.color) ?? Color(hex: "919399")
        let operatorColor = Style.getColor(theme: Style.model?.messages?.replyTextOperator?.color) ?? Color(hex: "919399")
        return isMy ? clientColor : operatorColor
    }
    
    var textFontSize: CGFloat {
        let clientFontSize = CGFloat(Style.model?.messages?.replyTextClient?.textSize ?? 15)
        let operatorFontSize = CGFloat(Style.model?.messages?.replyTextOperator?.textSize ?? 15)
        return isMy ? clientFontSize : operatorFontSize
    }
    
    var senderTextColor: Color {
        let clientColor = Style.getColor(theme: Style.model?.messages?.replySenderTextClient?.color) ?? Color.white
        let operatorColor = Style.getColor(theme: Style.model?.messages?.replySenderTextOperator?.color) ?? Color(hex: "242729")
        return isMy ? clientColor : operatorColor
    }
    
    var senderTextFontSize: CGFloat {
        let clientFontSize = CGFloat(Style.model?.messages?.replySenderTextClient?.textSize ?? 13)
        let operatorFontSize = CGFloat(Style.model?.messages?.replySenderTextOperator?.textSize ?? 13)
        return isMy ? clientFontSize : operatorFontSize
    }
    
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
                    Text(message.senderName)
                        .font(.system(size: senderTextFontSize))
                        .foregroundColor(senderTextColor)
                        .lineLimit(1)
                    
                    Text(message.messageText)
                        .font(.system(size: textFontSize))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                }
            }
            .frame(height: 34)
        }
    }
}
