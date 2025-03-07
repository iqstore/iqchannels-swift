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
    var isBold: Bool {
        let clientIsBold = Style.model?.messages?.textClient?.textStyle?.bold ?? false
        let operatorIsBold = Style.model?.messages?.textOperator?.textStyle?.bold ?? false
        return self.isSender ? clientIsBold : operatorIsBold
    }
    var isItalic: Bool {
        let clientIsItalic = Style.model?.messages?.textClient?.textStyle?.italic ?? false
        let operatorIsItalic = Style.model?.messages?.textOperator?.textStyle?.italic ?? false
        return self.isSender ? clientIsItalic : operatorIsItalic
    }
    var aligment: TextAlignment {
        let clientAlignment = stringToAlignment(stringAlignment: Style.model?.messages?.textClient?.textAlign) ?? .leading
        let operatorAlignment = stringToAlignment(stringAlignment: Style.model?.messages?.textOperator?.textAlign) ?? .leading
        return self.isSender ? clientAlignment : operatorAlignment
    }
    
    
    
    var backgroundColor: Color {
        let backgroundOperator = Style.getColor(theme: Style.model?.messages?.backgroundOperator?.color) ?? Color(hex: "F4F4F8")
        let backgroundClient = Style.getColor(theme: Style.model?.messages?.backgroundClient?.color) ?? Color(hex: "242729")
        return self.isSender ? backgroundClient : backgroundOperator
    }
    var backgroundRadius: CGFloat {
        let backgroundOperator = Style.model?.messages?.backgroundOperator?.border?.borderRadius ?? 12
        let backgroundClient = Style.model?.messages?.backgroundClient?.border?.borderRadius ?? 12
        return self.isSender ? backgroundClient : backgroundOperator
    }
    var backgroundBorderSize: CGFloat {
        let backgroundOperator = Style.model?.messages?.backgroundOperator?.border?.size ?? 0
        let backgroundClient = Style.model?.messages?.backgroundClient?.border?.size ?? 0
        return self.isSender ? backgroundClient : backgroundOperator
    }
    var backgroundBorderColor: Color {
        let backgroundOperator = Style.getColor(theme: Style.model?.messages?.backgroundOperator?.border?.color) ?? Color(hex: "000000")
        let backgroundClient = Style.getColor(theme: Style.model?.messages?.backgroundClient?.border?.color) ?? Color(hex: "000000")
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
    var fileNameIsBold: Bool {
        let clientIsBold = Style.model?.messagesFile?.textFilenameClient?.textStyle?.bold ?? false
        let operatorIsBold = Style.model?.messagesFile?.textFilenameOperator?.textStyle?.bold ?? false
        return self.isSender ? clientIsBold : operatorIsBold
    }
    var fileNameIsItalic: Bool {
        let clientIsItalic = Style.model?.messagesFile?.textFilenameClient?.textStyle?.italic ?? false
        let operatorIsItalic = Style.model?.messagesFile?.textFilenameOperator?.textStyle?.italic ?? false
        return self.isSender ? clientIsItalic : operatorIsItalic
    }
    var fileNameAligment: TextAlignment {
        let clientIsItalic = stringToAlignment(stringAlignment: Style.model?.messagesFile?.textFilenameClient?.textAlign) ?? .leading
        let operatorIsItalic = stringToAlignment(stringAlignment: Style.model?.messagesFile?.textFilenameOperator?.textAlign) ?? .leading
        return self.isSender ? clientIsItalic : operatorIsItalic
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
    var fileSizeIsBold: Bool {
        let clientIsBold = Style.model?.messagesFile?.textFileSizeClient?.textStyle?.bold ?? false
        let operatorIsBold = Style.model?.messagesFile?.textFileSizeOperator?.textStyle?.bold ?? false
        return self.isSender ? clientIsBold : operatorIsBold
    }
    var fileSizeIsItalic: Bool {
        let clientIsItalic = Style.model?.messagesFile?.textFileSizeClient?.textStyle?.italic ?? false
        let operatorIsItalic = Style.model?.messagesFile?.textFileSizeOperator?.textStyle?.italic ?? false
        return self.isSender ? clientIsItalic : operatorIsItalic
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
                                                                     fontSize: fontSize,
                                                                     alingment: aligment,
                                                                     isBold: isBold,
                                                                     isItalic: isItalic)
                    if #available(iOS 16.0, *) {
                        TextLabel(text: data.0,
                                  linkRanges: data.1)
                        .layoutPriority(1)
                        .bold(isBold)
                        .italic(isItalic)
                    } else {
                        TextLabel(text: data.0,
                                  linkRanges: data.1)
                        .layoutPriority(1)
                    }
                }
            }
            MessageStatusView(message: message)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(backgroundColor)
        .cornerRadius(backgroundRadius)
        .overlay(
            RoundedRectangle(cornerRadius: backgroundRadius)
                .stroke(backgroundBorderColor, lineWidth: backgroundBorderSize)
        )
        .animation(.bouncy, value: message.file?.isLoading)
        .onTapGesture {
            if let file = message.file {
                if let state = file.state {
                    if state == .approved {
                        onFileTapCompletion?()
                    }
                } else {
                    onFileTapCompletion?()
                }
            }
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
                if #available(iOS 16.0, *) {
                    Text(file.name ?? "")
                        .foregroundColor(fileNameTextColor)
                        .font(.system(size: fileNameFontSize))
                        .bold(fileNameIsBold)
                        .italic(fileNameIsItalic)
                        .multilineTextAlignment(fileNameAligment)
                } else {
                    Text(file.name ?? "")
                        .foregroundColor(fileNameTextColor)
                        .font(.system(size: fileNameFontSize))
                        .multilineTextAlignment(fileNameAligment)
                }
                
                if #available(iOS 16.0, *) {
                    Text(file.convertedSize)
                        .foregroundColor(fileSizeTextColor)
                        .font(.system(size: fileSizeFontSize))
                        .bold(fileSizeIsBold)
                        .italic(fileSizeIsItalic)
                } else {
                    Text(file.convertedSize)
                        .foregroundColor(fileSizeTextColor)
                        .font(.system(size: fileSizeFontSize))
                }
            }
        }
    }
    
    @ViewBuilder
    private func getNotApprovedStateView(_ state: IQFileState) -> some View {
        let textColor: Color = isSender ? state.titleClientColor : state.titleOperatorColor
        let fontSize: CGFloat = isSender ? state.titleClientFontSize : state.titleOperatorFontSize
        let alignment: TextAlignment = isSender ? state.titleClientAligment: state.titleOperatorAligment
        let isBold: Bool = isSender ? state.titleClientIsBold : state.titleOperatorIsBold
        let isItalic: Bool = isSender ? state.titleClientIsItalic : state.titleOperatorIsItalic
        
        if #available(iOS 16.0, *) {
            Text(state.title)
                .foregroundColor(textColor)
                .font(.system(size: fontSize))
                .bold(isBold)
                .italic(isItalic)
                .multilineTextAlignment(alignment)
        } else {
            Text(state.title)
                .foregroundColor(textColor)
                .font(.system(size: fontSize))
                .multilineTextAlignment(alignment)
        }
    }
}
