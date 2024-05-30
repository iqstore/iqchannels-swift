import SwiftUI

struct FilePreviewCellView: View {
    
    // MARK: - PROPERTIES
    private let message: IQMessage
    private let replyMessage: IQMessage?
    private let onFileTapCompletion: (() -> Void)?
    private let onCancelFileSendCompletion: (() -> Void)?
    private let onReplyMessageTapCompletion: ((Int) -> Void)?
    private let isSender: Bool
    private let tintColor: Color
    private let backgroundColor: Color
    
    @State private var showMessageLoading: Bool = false
    
    // MARK: - INIT
    init(message: IQMessage,
         replyMessage: IQMessage? = nil,
         onFileTapCompletion: (() -> Void)? = nil,
         onCancelFileSendCompletion: (() -> Void)? = nil,
         onReplyMessageTapCompletion: ((Int) -> Void)? = nil) {
        self.message = message
        self.replyMessage = replyMessage
        self.onFileTapCompletion = onFileTapCompletion
        self.onCancelFileSendCompletion = onCancelFileSendCompletion
        self.onReplyMessageTapCompletion = onReplyMessageTapCompletion
        self.isSender = message.isMy ?? false
        self.tintColor = self.isSender ? Color.white : Color(hex: "242729")
        self.backgroundColor = self.isSender ? Color(hex: "242729") : Color(hex: "F4F4F8")
    }
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                if let replyMessage {
                    MessageReplyView(message: replyMessage,
                                     isMy: message.isMy ?? false,
                                     onReplyMessageTapCompletion: onReplyMessageTapCompletion)
                }
                
                if let file = message.file {
                    HStack(spacing: 8) {
                        if file.isLoading {
                            Button {
                                onCancelFileSendCompletion?()
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
                        } else {
                            Image(name: "file")
                                .renderingMode(.template)
                                .resizable()
                                .foregroundColor(tintColor)
                                .frame(width: 32, height: 32)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.name ?? "")
                                .foregroundColor(tintColor)
                                .font(.system(size: 17))
                                .multilineTextAlignment(.leading)
                            
                            Text(file.convertedSize)
                                .foregroundColor(Color(hex: "919399"))
                                .font(.system(size: 15))
                        }
                    }
                }
            }
            
            MessageStatusView(message: message)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(backgroundColor)
        .cornerRadius(12)
        .animation(.bouncy, value: message.file?.isLoading)
        .onTapGesture {
            onFileTapCompletion?()
        }
    }
}
