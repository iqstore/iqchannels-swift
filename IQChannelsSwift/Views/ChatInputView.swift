import SwiftUI
import SDWebImageSwiftUI

enum CustomTextAreaConfig {
    static let minHeight: CGFloat = 40
    static let maxHeight: CGFloat = 120
    static let maxMessageSymbols: Int = 4096
}

struct ChatInputView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
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
                if let iconClipUrl = Style.model?.toolsToMessage?.iconClip {
                    AnimatedImage(url: iconClipUrl)
                        .resizable()
                        .indicator(SDWebImageActivityIndicator.gray)
                        .transition(SDWebImageTransition.fade)
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .background(Color(hex: "F4F4F8"))
                        .clipShape(Circle())
                } else {
                    Image(name: "attachment")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .background(Color(hex: "F4F4F8"))
                        .clipShape(Circle())
                }
            }
            
            let chatBackgroundColor = Style.getColor(theme: Style.model?.toolsToMessage?.backgroundChat) ?? Color(hex: "F4F4F8")
            let textColor = Style.getUIColor(theme: Style.model?.toolsToMessage?.textChat?.color) ?? UIColor(hex: "242729")
            let fontSize = CGFloat(Style.model?.toolsToMessage?.textChat?.textSize ?? 17)
            ComposerInputView(text: $text,
                              height: $textAreaHeight,
                              textColor: textColor,
                              fontSize: fontSize,
                              currentHeight: finalTextAreaHeight)
                .frame(height: finalTextAreaHeight)
                .placeholder(when: text.isEmpty) {
                    Text("Сообщение")
                        .font(.system(size: fontSize))
                        .foregroundColor(Color(hex: "919399"))
                        .padding(.leading, 8)
                }
                .padding(.horizontal, 8)
                .background(chatBackgroundColor)
                .cornerRadius(CustomTextAreaConfig.minHeight / 2)
            
            Group {
                if !text.isEmpty {
                    let backgroundColor = Style.getColor(theme: Style.model?.toolsToMessage?.backgroundIcon) ?? Color(hex: "242729")
                    Button {
                        onSendCompletion?()
                    } label: {
                        if let iconSentUrl = Style.model?.toolsToMessage?.iconSent {
                            AnimatedImage(url: iconSentUrl)
                                .resizable()
                                .indicator(SDWebImageActivityIndicator.gray)
                                .transition(SDWebImageTransition.fade)
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .padding(8)
                                .background(backgroundColor)
                                .clipShape(Circle())
                        } else {
                            Image(name: "up_arrow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .padding(8)
                                .background(backgroundColor)
                                .clipShape(Circle())
                        }
                    }
                    .transition(.move(edge: .trailing))
                }
            }
            .opacity(text.isEmpty ? 0 : 1)
        }
        .animation(.bouncy, value: text.isEmpty)
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private func getReplyPreview(message: IQMessage) -> some View {
        let backgroundColor = Style.getColor(theme: Style.model?.answer?.backgroundTextUpMessage) ?? Color.clear
        HStack(spacing: 8) {
            let capsuleTintColor = Style.getColor(theme: Style.model?.answer?.leftLine) ?? Color(hex: "DD0A34")
            Capsule()
                .fill(capsuleTintColor)
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
                let senderTextColor = Style.getColor(theme: Style.model?.answer?.textSender?.color) ?? Color(hex: "919399")
                let senderFontSize = CGFloat(Style.model?.answer?.textSender?.textSize ?? 13)
                Text(message.senderName)
                    .font(.system(size: senderFontSize))
                    .foregroundColor(senderTextColor)
                    .lineLimit(1)
                
                let messageTextColor = Style.getColor(theme: Style.model?.answer?.textMessage?.color) ?? Color(hex: "242729")
                let messageFontSize = CGFloat(Style.model?.answer?.textMessage?.textSize ?? 15)
                Text(message.messageText)
                    .font(.system(size: messageFontSize))
                    .foregroundColor(messageTextColor)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
            
            Button {
                messageToReply = nil
            } label: {
                if let iconCancelUrl = Style.model?.answer?.iconCancel {
                    AnimatedImage(url: iconCancelUrl)
                        .resizable()
                        .indicator(SDWebImageActivityIndicator.gray)
                        .transition(SDWebImageTransition.fade)
                        .frame(width: 24, height: 24)
                } else {
                    Image(name: "close_fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
        }
        .frame(height: 56)
        .padding(.horizontal, 8)
        .background(backgroundColor)
    }
}
