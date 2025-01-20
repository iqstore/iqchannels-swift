import SwiftUI
import Combine
import SDWebImageSwiftUI

struct MediaMessageCellView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    private let message: IQMessage
    private let replyMessage: IQMessage?
    private let onImageTapCompletion: (() -> Void)?
    private let onCancelImageSendCompletion: (() -> Void)?
    private let onReplyMessageTapCompletion: ((Int) -> Void)?
    
    private let text: String
    private let isSender: Bool
    
    @State private var showMessageLoading: Bool = false
    
    var backgroundColor: Color {
        let backgroundClient = Style.getColor(theme: Style.model?.messages?.backgroundClient?.color) ?? Color(hex: "242729")
        let backgroundOperator = Style.getColor(theme: Style.model?.messages?.backgroundOperator?.color) ?? Color(hex: "F4F4F8")
        return self.isSender ? backgroundClient : backgroundOperator
    }
    
    var textColor: UIColor {
        let textOperator = Style.getUIColor(theme: Style.model?.messages?.textOperator?.color) ?? UIColor(hex: "242729")
        let textClient = Style.getUIColor(theme: Style.model?.messages?.textClient?.color) ?? UIColor.white
        return self.isSender ? textClient : textOperator
    }
    
    var fontSize: CGFloat {
        let sizeOperator = CGFloat(Style.model?.messages?.textOperator?.textSize ?? 17)
        let sizeClient = CGFloat(Style.model?.messages?.textClient?.textSize ?? 17)
        return self.isSender ? sizeClient : sizeOperator
    }
    
    // MARK: - INIT
    init(message: IQMessage,
         replyMessage: IQMessage? = nil,
         onImageTapCompletion: (() -> Void)? = nil,
         onCancelImageSendCompletion: (() -> Void)? = nil,
         onReplyMessageTapCompletion: ((Int) -> Void)? = nil) {
        self.message = message
        self.replyMessage = replyMessage
        self.onImageTapCompletion = onImageTapCompletion
        self.onCancelImageSendCompletion = onCancelImageSendCompletion
        self.onReplyMessageTapCompletion = onReplyMessageTapCompletion
        self.text = message.text ?? ""
        self.isSender = message.isMy
    }
    
    // MARK: - BODY
    var body: some View {
        let imageSize = calculateImageSize(file: message.file)
        VStack(alignment: .leading, spacing: 4) {
            if let replyMessage {
                MessageReplyView(message: replyMessage,
                                 isMy: message.isMy,
                                 onReplyMessageTapCompletion: onReplyMessageTapCompletion)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            
            VStack(alignment: .trailing){
                ZStack(alignment: .bottomTrailing) {
                    if let file = message.file {
                        if file.isLoading {
                            if let data = file.dataFile?.data,
                               let uiImage = UIImage(data: data) {
                                ZStack {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: imageSize.width, height: imageSize.height)
                                    
                                    Button {
                                        onCancelImageSendCompletion?()
                                    } label: {
                                        ZStack {
                                            Image(name: "loading")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                                .rotationEffect(Angle(degrees: showMessageLoading ? 360 : 0.0))
                                            
                                            Image(name: "xmark")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 12, height: 12)
                                        }
                                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: showMessageLoading)
                                        .onAppear { self.showMessageLoading = true }
                                    }
                                }
                            }
                        } else {
                            AnimatedImage(url: message.file?.imagePreviewUrl)
                                .resizable()
                                .indicator(SDWebImageActivityIndicator.gray)
                                .transition(SDWebImageTransition.fade)
                                .scaledToFill()
                                .frame(width: imageSize.width, height: imageSize.height)
                                .clipped()
                        }
                    }
                    
                    if(text == ""){
                        MessageStatusView(message: message, withBackground: true)
                            .padding(8)
                    }
                }
                
                if(text != ""){
                    let data = AttributeTextManager.shared.getString(from: text,
                                                                     textColor: textColor,
                                                                     fontSize: fontSize)
                    TextLabel(text: data.0,
                              linkRanges: data.1)
                    .layoutPriority(1)
                    .padding(.horizontal, 12)
                    
                    MessageStatusView(message: message)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                }
            }
        }
        .background(backgroundColor)
        .cornerRadius(12)
        .animation(.bouncy, value: message.file?.isLoading)
        .onTapGesture {
            onImageTapCompletion?()
        }
    }
    
    // MARK: - METHODS
    private func calculateImageSize(file: IQFile?) -> CGSize {
        let maxWidth = CGFloat(210)
        let maxHeight = CGFloat(150)
        let minWidth = CGFloat(100)
        
        if file?.isLoading ?? false {
            guard let data = file?.dataFile?.data,
                  let image = UIImage(data: data) else {
                return CGSize(width: maxWidth, height: maxHeight)
            }
            
            if image.size.width > image.size.height {
                let height = maxWidth * image.size.height / image.size.width
                return CGSize(width: maxWidth, height: height)
            } else {
                let width = maxHeight * image.size.width / image.size.height
                return CGSize(width: max(width, minWidth), height: maxHeight)
            }
        } else {
            guard let width = file?.imageWidth,
                  let height = file?.imageHeight else {
                return CGSize(width: maxWidth, height: maxHeight)
            }
            
            let widthScale = maxWidth / CGFloat(width)
            let heightScale = maxHeight / CGFloat(height)
            
            let scaleFactor = min(widthScale, heightScale)
            
            return CGSize(width: max(Double(CGFloat(width) * scaleFactor), minWidth),
                          height: Double(CGFloat(height) * scaleFactor))
        }
    }
}
