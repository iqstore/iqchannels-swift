import SwiftUI
import SDWebImageSwiftUI

struct FilePreviewCellView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    private let message: IQMessage
    private let replyMessage: IQMessage?
    private let onFileTapCompletion: (() -> Void)?
    private let onCancelFileSendCompletion: (() -> Void)?
    private let onReplyMessageTapCompletion: ((Int) -> Void)?
    private let text: String
    private let isSender: Bool
    
    @State private var showMessageLoading: Bool = false
    
    
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
    
    var backgroundColor: Color {
        let backgroundOperator = Style.getColor(theme: Style.model?.messages?.backgroundOperator) ?? Color(hex: "F4F4F8")
        let backgroundClient = Style.getColor(theme: Style.model?.messages?.backgroundClient) ?? Color(hex: "242729")
        return self.isSender ? backgroundClient : backgroundOperator
    }
    
    var fileNameTextColor: Color {
        let clientColor = Style.getColor(theme: Style.model?.messagesFile?.textFilenameClient?.color) ?? Color.white
        let operatorColor = Style.getColor(theme: Style.model?.messagesFile?.textFilenameOperator?.color) ?? Color(hex: "242729")
        return self.isSender ? clientColor : operatorColor
    }
    
    var fileNameFontSize: CGFloat {
        let clientFontSize = CGFloat(Style.model?.messagesFile?.textFilenameClient?.textSize ?? 17)
        let operatorFontSize = CGFloat(Style.model?.messagesFile?.textFilenameOperator?.textSize ?? 17)
        return self.isSender ? clientFontSize : operatorFontSize
    }
    
    var fileIcon: URL? {
        let clientFile = Style.model?.messagesFile?.iconFileClient
        let operatorFile = Style.model?.messagesFile?.iconFileOperator
        return self.isSender ? clientFile : operatorFile
    }
    
    var fileSizeTextColor: Color {
        let clientColor = Style.getColor(theme: Style.model?.messagesFile?.textFileSizeClient?.color) ?? Color(hex: "919399")
        let operatorColor = Style.getColor(theme: Style.model?.messagesFile?.textFileSizeOperator?.color) ?? Color(hex: "919399")
        return self.isSender ? clientColor : operatorColor
    }
    
    var fileSizeFontSize: CGFloat {
        let clientFontSize = CGFloat(Style.model?.messagesFile?.textFileSizeClient?.textSize ?? 15)
        let operatorFontSize = CGFloat(Style.model?.messagesFile?.textFileSizeOperator?.textSize ?? 15)
        return self.isSender ? clientFontSize : operatorFontSize
    }
    
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
        self.text = message.text ?? ""
        self.isSender = message.isMy
    }
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                if let replyMessage {
                    MessageReplyView(message: replyMessage,
                                     isMy: message.isMy,
                                     onReplyMessageTapCompletion: onReplyMessageTapCompletion)
                }
                
                if let file = message.file {
                    if let state = file.state {
                        if state == .approved {
                            getApprovedStateView(file)
                        } else {
                            getNotApprovedStateView(state)
                        }
                    } else {
                        getApprovedStateView(file)
                    }
                }
            }
            
            if(text != ""){
                let data = AttributeTextManager.shared.getString(from: text,
                                                                 textColor: textColor,
                                                                 fontSize: fontSize)
                TextLabel(text: data.0,
                          linkRanges: data.1)
                .layoutPriority(1)
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
    
    // MARK: - VIEWS
    @ViewBuilder
    private func getApprovedStateView(_ file: IQFile) -> some View {
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
                if let fileIcon {
                    AnimatedImage(url: fileIcon)
                        .resizable()
                        .indicator(SDWebImageActivityIndicator.gray)
                        .transition(SDWebImageTransition.fade)
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                } else {
                    Image(name: "file")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(fileNameTextColor)
                        .frame(width: 32, height: 32)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name ?? "")
                    .foregroundColor(fileNameTextColor)
                    .font(.system(size: fileNameFontSize))
                    .multilineTextAlignment(.leading)
                
                Text(file.convertedSize)
                    .foregroundColor(fileSizeTextColor)
                    .font(.system(size: fileSizeFontSize))
            }
        }
    }
    
    @ViewBuilder
    private func getNotApprovedStateView(_ state: IQFileState) -> some View {
        let textColor: Color = isSender ? state.titleClientColor : state.titleOperatorColor
        let fontSize: CGFloat = isSender ? state.titleClientFontSize : state.titleOperatorFontSize
        
        Text(state.title)
            .foregroundColor(textColor)
            .font(.system(size: fontSize))
    }
}
