import SwiftUI
import SDWebImageSwiftUI

struct MessageReplyView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let message: IQMessage
    let isMy: Bool
    let onReplyMessageTapCompletion: ((Int) -> Void)?
    
    var textColor: Color {
        let clientColor = IQStyle.getColor(theme: IQStyle.model?.messages?.replyTextClient?.color) ?? Color(hex: "919399")
        let operatorColor = IQStyle.getColor(theme: IQStyle.model?.messages?.replyTextOperator?.color) ?? Color(hex: "919399")
        return isMy ? clientColor : operatorColor
    }
    var textFontSize: CGFloat {
        let clientFontSize = CGFloat(IQStyle.model?.messages?.replyTextClient?.textSize ?? 15)
        let operatorFontSize = CGFloat(IQStyle.model?.messages?.replyTextOperator?.textSize ?? 15)
        return isMy ? clientFontSize : operatorFontSize
    }
    var textIsBold: Bool {
        let clientIsBold = IQStyle.model?.messages?.replyTextClient?.textStyle?.bold ?? false
        let operatorIsBold = IQStyle.model?.messages?.replyTextOperator?.textStyle?.bold ?? false
        return isMy ? clientIsBold : operatorIsBold
    }
    var textIsItalic: Bool {
        let clientIsItalic = IQStyle.model?.messages?.replyTextClient?.textStyle?.italic ?? false
        let operatorIsItalic = IQStyle.model?.messages?.replyTextOperator?.textStyle?.italic ?? false
        return isMy ? clientIsItalic : operatorIsItalic
    }
    var textAlignment: TextAlignment {
        let clientIsItalic = stringToAlignment(stringAlignment: IQStyle.model?.messages?.replyTextClient?.textAlign)  ?? .leading
        let operatorIsItalic = stringToAlignment(stringAlignment: IQStyle.model?.messages?.replyTextOperator?.textAlign) ?? .leading
        return isMy ? clientIsItalic : operatorIsItalic
    }
    
    
    
    
    
    
    
    var senderTextColor: Color {
        let clientColor = IQStyle.getColor(theme: IQStyle.model?.messages?.replySenderTextClient?.color) ?? Color.white
        let operatorColor = IQStyle.getColor(theme: IQStyle.model?.messages?.replySenderTextOperator?.color) ?? Color(hex: "242729")
        return isMy ? clientColor : operatorColor
    }
    var senderTextFontSize: CGFloat {
        let clientFontSize = CGFloat(IQStyle.model?.messages?.replySenderTextClient?.textSize ?? 13)
        let operatorFontSize = CGFloat(IQStyle.model?.messages?.replySenderTextOperator?.textSize ?? 13)
        return isMy ? clientFontSize : operatorFontSize
    }
    var senderTextIsBold: Bool {
        let clientIsBold = IQStyle.model?.messages?.replySenderTextClient?.textStyle?.bold ?? false
        let operatorIsBold = IQStyle.model?.messages?.replySenderTextOperator?.textStyle?.bold ?? false
        return isMy ? clientIsBold : operatorIsBold
    }
    var senderTextIsItalic: Bool {
        let clientIsItalic = IQStyle.model?.messages?.replySenderTextClient?.textStyle?.italic ?? false
        let operatorIsItalic = IQStyle.model?.messages?.replySenderTextOperator?.textStyle?.italic ?? false
        return isMy ? clientIsItalic : operatorIsItalic
    }
    var senderTextAlignment: TextAlignment {
        let clientIsItalic = stringToAlignment(stringAlignment: IQStyle.model?.messages?.replySenderTextClient?.textAlign)  ?? .leading
        let operatorIsItalic = stringToAlignment(stringAlignment: IQStyle.model?.messages?.replySenderTextOperator?.textAlign) ?? .leading
        return isMy ? clientIsItalic : operatorIsItalic
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
                    if #available(iOS 16.0, *) {
                        Text(message.senderName)
                            .font(.system(size: senderTextFontSize))
                            .foregroundColor(senderTextColor)
                            .bold(senderTextIsBold)
                            .italic(senderTextIsItalic)
                            .multilineTextAlignment(senderTextAlignment)
                            .lineLimit(1)
                    } else {
                        Text(message.senderName)
                            .font(.system(size: senderTextFontSize))
                            .foregroundColor(senderTextColor)
                            .multilineTextAlignment(senderTextAlignment)
                            .lineLimit(1)
                    }
                    
                    if #available(iOS 16.0, *) {
                        Text(message.messageText)
                            .font(.system(size: textFontSize))
                            .foregroundColor(textColor)
                            .bold(textIsBold)
                            .italic(textIsItalic)
                            .multilineTextAlignment(textAlignment)
                            .lineLimit(1)
                    } else {
                        Text(message.messageText)
                            .font(.system(size: textFontSize))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(textAlignment)
                            .lineLimit(1)
                    }
                }
            }
            .frame(height: 34)
        }
    }
}
