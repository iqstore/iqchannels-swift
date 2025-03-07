import SwiftUI
import SDWebImageSwiftUI

enum CustomTextAreaConfig {
    static let minHeight: CGFloat = 40
    static let maxHeight: CGFloat = 120
    static let maxMessageSymbols: Int = 4096
}

struct ChatInputView: View {
    
    // MARK: - PROPERTIES
    @EnvironmentObject var viewModel: IQChatDetailViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var text: String
    @Binding var messageToReply: IQMessage?
    @Binding var selectedFiles: [DataFile]?
    
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
            
            
            
            Group {
                if let selectedFiles {
                    VStack(spacing: 0) {
                        Divider()
                        getFilePreview(files: selectedFiles)
                        
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .opacity(selectedFiles == nil ? 0 : 1)
            
            
            getTextFieldView()
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3), value: messageToReply)
        .allowsHitTesting(!disableInput)
    }
    
    var showSendButton: Bool {
        return !text.isEmpty || selectedFiles != nil
    }
    
    // MARK: - VIEWS
    @ViewBuilder
    private func getTextFieldView() -> some View {
        let backgroundColor = Style.getColor(theme: Style.model?.toolsToMessage?.background) ?? Color.clear
        
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
            
            let inputBackgroundColor = Style.getColor(theme: Style.model?.toolsToMessage?.backgroundInput?.color) ?? Color(hex: "F4F4F8")
            let textColor = Style.getUIColor(theme: Style.model?.toolsToMessage?.textInput?.color) ?? UIColor(hex: "242729")
            let fontSize = CGFloat(Style.model?.toolsToMessage?.textInput?.textSize ?? 17)
            
            let radius = Style.model?.toolsToMessage?.backgroundInput?.border?.borderRadius ?? 8
            let borderSize = Style.model?.toolsToMessage?.backgroundInput?.border?.size ?? 0
            let borderColor = Style.getColor(theme: Style.model?.toolsToMessage?.backgroundInput?.border?.color) ?? Color(hex: "000000")
            
            
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
                .background(inputBackgroundColor)
                .cornerRadius(radius)
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(borderColor, lineWidth: borderSize)
                )
            
            Group {
                if showSendButton {
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
            .opacity(showSendButton ? 1 : 0)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3), value: showSendButton)
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(backgroundColor)
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
                let senderAlignment = stringToAlignment(stringAlignment: Style.model?.answer?.textSender?.textAlign) ?? .leading
                let senderIsBold = Style.model?.answer?.textSender?.textStyle?.bold ?? false
                let senderIsItalic = Style.model?.answer?.textSender?.textStyle?.italic ?? false
                
                if #available(iOS 16.0, *) {
                    Text(message.senderName)
                        .font(.system(size: senderFontSize))
                        .foregroundColor(senderTextColor)
                        .multilineTextAlignment(senderAlignment)
                        .bold(senderIsBold)
                        .italic(senderIsItalic)
                        .lineLimit(1)
                } else {
                    Text(message.senderName)
                        .font(.system(size: senderFontSize))
                        .foregroundColor(senderTextColor)
                        .multilineTextAlignment(senderAlignment)
                        .lineLimit(1)
                }
                
                let messageTextColor = Style.getColor(theme: Style.model?.answer?.textMessage?.color) ?? Color(hex: "242729")
                let messageFontSize = CGFloat(Style.model?.answer?.textMessage?.textSize ?? 15)
                let messageAlignment = stringToAlignment(stringAlignment: Style.model?.answer?.textMessage?.textAlign) ?? .leading
                let messageIsBold = Style.model?.answer?.textMessage?.textStyle?.bold ?? false
                let messageIsItalic = Style.model?.answer?.textMessage?.textStyle?.italic ?? false
                
                if #available(iOS 16.0, *) {
                    Text(message.messageText)
                        .font(.system(size: messageFontSize))
                        .foregroundColor(messageTextColor)
                        .multilineTextAlignment(senderAlignment)
                        .bold(senderIsBold)
                        .italic(senderIsItalic)
                        .lineLimit(1)
                } else {
                    Text(message.messageText)
                        .font(.system(size: messageFontSize))
                        .foregroundColor(messageTextColor)
                        .multilineTextAlignment(senderAlignment)
                        .lineLimit(1)
                }
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
    
    func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    @ViewBuilder
    private func getFilePreview(files: [DataFile]) -> some View {
        let backgroundColor = Style.getColor(theme: Style.model?.answer?.backgroundTextUpMessage) ?? Color.clear
        
        let fileNameTextColor = Style.getColor(theme: Style.model?.messagesFile?.textFilenameOperator?.color) ?? Color(hex: "242729")
        let fileNameFontSize = CGFloat(Style.model?.messagesFile?.textFilenameOperator?.textSize ?? 17)
        let fileNameAlignment = stringToAlignment(stringAlignment: Style.model?.messagesFile?.textFilenameOperator?.textAlign) ?? .leading
        let fileNameIsBold = Style.model?.messagesFile?.textFilenameOperator?.textStyle?.bold ?? false
        let fileNameIsItalic = Style.model?.messagesFile?.textFilenameOperator?.textStyle?.italic ?? false
        
        
        let fileSizeTextColor = Style.getColor(theme: Style.model?.messagesFile?.textFileSizeOperator?.color) ?? Color(hex: "919399")
        let fileSizeFontSize = CGFloat(Style.model?.messagesFile?.textFileSizeOperator?.textSize ?? 15)
        let fileSizeAlignment = stringToAlignment(stringAlignment: Style.model?.messagesFile?.textFileSizeOperator?.textAlign) ?? .leading
        let fileSizeIsBold = Style.model?.messagesFile?.textFileSizeOperator?.textStyle?.bold ?? false
        let fileSizeIsItalic = Style.model?.messagesFile?.textFileSizeOperator?.textStyle?.italic ?? false
        
        HStack(spacing: 8) {
            Image(name: "file")
                .renderingMode(.template)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(fileNameTextColor)
            
            VStack(alignment: .leading, spacing: 0) {
                if #available(iOS 16.0, *) {
                    Text(files.first?.filename ?? "Файл")
                        .font(.system(size: fileNameFontSize))
                        .foregroundColor(fileNameTextColor)
                        .multilineTextAlignment(fileNameAlignment)
                        .bold(fileNameIsBold)
                        .italic(fileNameIsItalic)
                        .lineLimit(2)
                } else {
                    Text(files.first?.filename ?? "Файл")
                        .font(.system(size: fileNameFontSize))
                        .foregroundColor(fileNameTextColor)
                        .multilineTextAlignment(fileNameAlignment)
                        .lineLimit(2)
                }
                
                if #available(iOS 16.0, *) {
                    Text(formatBytes(files.first?.data.count ?? 0))
                        .font(.system(size: fileSizeFontSize))
                        .foregroundColor(fileSizeTextColor)
                        .multilineTextAlignment(fileSizeAlignment)
                        .bold(fileSizeIsBold)
                        .italic(fileSizeIsItalic)
                        .lineLimit(1)
                } else {
                    Text(formatBytes(files.first?.data.count ?? 0))
                        .font(.system(size: fileSizeFontSize))
                        .foregroundColor(fileSizeTextColor)
                        .multilineTextAlignment(fileSizeAlignment)
                        .lineLimit(1)
                }
            }
            
            Spacer(minLength: 0)
            
            if (files.count > 1){
                if #available(iOS 16.0, *) {
                    Text("+ \(files.count - 1)")
                        .font(.system(size: fileNameFontSize))
                        .foregroundColor(fileNameTextColor)
                        .multilineTextAlignment(fileNameAlignment)
                        .bold(fileNameIsBold)
                        .italic(fileNameIsItalic)
                        .lineLimit(1)
                } else {
                    Text("+ \(files.count - 1)")
                        .font(.system(size: fileNameFontSize))
                        .foregroundColor(fileNameTextColor)
                        .multilineTextAlignment(fileNameAlignment)
                        .lineLimit(1)
                }
            }
            
            Button {
                selectedFiles = nil
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
