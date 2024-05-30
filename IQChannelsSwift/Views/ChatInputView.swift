import SwiftUI
import SDWebImageSwiftUI

enum CustomTextAreaConfig {
    static let minHeight: CGFloat = 40
    static let maxHeight: CGFloat = 120
    static let maxMessageSymbols: Int = 4096
}

struct ChatInputView: View {
    
    // MARK: - PROPERTIES
    @Binding var text: String
    @Binding var messageToReply: IQMessage?
    let disableInput: Bool
    
    let onAttachmentCompletion: (() -> Void)?
    let onSendCompletion: (() -> Void)?
    
    @State private var textAreaHeight: CGFloat = CustomTextAreaConfig.minHeight
    
    private var finalTextAreaHeight: CGFloat {
        if textAreaHeight < CustomTextAreaConfig.minHeight {
            return CustomTextAreaConfig.minHeight
        }

        if textAreaHeight > CustomTextAreaConfig.maxHeight {
            return CustomTextAreaConfig.maxHeight
        }

        return textAreaHeight
    }
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            Group {
                if let messageToReply {
                    VStack(spacing: 0) {
                        Divider()
                        getReplyPreview(message: messageToReply)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .opacity(messageToReply == nil ? 0 : 1)
            
            getTextFieldView()
        }
        .animation(.bouncy, value: messageToReply)
        .allowsHitTesting(!disableInput)
    }
    
    // MARK: - VIEWS
    @ViewBuilder
    private func getTextFieldView() -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            Button {
                onAttachmentCompletion?()
            } label: {
                Image(name: "attachment")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(8)
                    .background(Color(hex: "F4F4F8"))
                    .clipShape(Circle())
            }
            
            ComposerInputView(text: $text, height: $textAreaHeight, currentHeight: finalTextAreaHeight)
                .frame(height: finalTextAreaHeight)
                .placeholder(when: text.isEmpty) {
                    Text("Сообщение")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "919399"))
                        .padding(.leading, 8)
                }
                .padding(.horizontal, 8)
                .background(Color(hex: "F4F4F8"))
                .cornerRadius(CustomTextAreaConfig.minHeight / 2)
            
            Group {
                if !text.isEmpty {
                    Button {
                        onSendCompletion?()
                    } label: {
                        Image(name: "up_arrow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(8)
                            .background(Color(hex: "242729"))
                            .clipShape(Circle())
                    }
                    .transition(.slide)
                }
            }
            .opacity(text.isEmpty ? 0 : 1)
        }
        .animation(.bouncy, value: text.isEmpty)
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    @ViewBuilder
    private func getReplyPreview(message: IQMessage) -> some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(Color(hex: "DD0A34"))
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
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "919399"))
                    .lineLimit(1)
                
                Text(message.messageText)
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "242729"))
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
            
            Button {
                messageToReply = nil
            } label: {
                Image(name: "close_fill")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 8)
    }
}
