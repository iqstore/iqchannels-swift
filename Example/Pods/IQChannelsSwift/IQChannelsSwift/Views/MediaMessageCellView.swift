import SwiftUI
import Combine
import SDWebImageSwiftUI

struct MediaMessageCellView: View {
    
    // MARK: - PROPERTIES
    private let message: IQMessage
    private let replyMessage: IQMessage?
    private let onImageTapCompletion: (() -> Void)?
    private let onCancelImageSendCompletion: (() -> Void)?
    private let onReplyMessageTapCompletion: ((Int) -> Void)?
    private let isSender: Bool
    private let backgroundColor: Color
    
    @State private var showMessageLoading: Bool = false
    
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
        self.isSender = message.isMy ?? false
        self.backgroundColor = self.isSender ? Color(hex: "242729") : Color(hex: "F4F4F8")
    }
    
    // MARK: - BODY
    var body: some View {
        let imageSize = calculateImageSize(file: message.file)
        VStack(alignment: .leading, spacing: 4) {
            if let replyMessage {
                MessageReplyView(message: replyMessage,
                                 isMy: message.isMy ?? false,
                                 onReplyMessageTapCompletion: onReplyMessageTapCompletion)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            
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
                
                MessageStatusView(message: message, withBackground: true)
                    .padding(8)
            }
        }
        .background(backgroundColor)
        .cornerRadius(12)
        .frame(maxWidth: imageSize.width)
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
