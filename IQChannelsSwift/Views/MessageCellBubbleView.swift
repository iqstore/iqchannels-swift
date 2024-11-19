import SwiftUI

struct MessageCellBubbleView: View {
    
    // MARK: - PROPERTIES
    private let message: IQMessage
    private let replyMessage: IQMessage?
    private let isLastMessage: Bool
    private let onLongPress: ((MessageControlInfo) -> Void)?
    private let onReplyMessageTapCompletion: ((Int) -> Void)?
    private let isSender: Bool
    private let backgroundColor: Color
    private let textColor: Color
    private let secondaryColor: Color
    private weak var delegate: ChatDetailViewDelegate?
    
    // MARK: - INIT
    init(message: IQMessage,
         replyMessage: IQMessage?,
         isLastMessage: Bool,
         onLongPress: ((MessageControlInfo) -> Void)? = nil,
         onReplyMessageTapCompletion: ((Int) -> Void)? = nil,
         delegate: ChatDetailViewDelegate? = nil) {
        self.message = message
        self.replyMessage = replyMessage
        self.isLastMessage = isLastMessage
        self.onLongPress = onLongPress
        self.onReplyMessageTapCompletion = onReplyMessageTapCompletion
        self.isSender = message.isMy
        self.backgroundColor = self.isSender ? Color(hex: "242729") : Color(hex: "F4F4F8")
        self.textColor = self.isSender ? Color.white : Color(hex: "242729")
        self.secondaryColor = Color(hex: "919399")
        self.delegate = delegate
    }
    
    // MARK: - BODY
    var body: some View {
        switch message.payload {
        case .text:
            if message.isPendingRatingMessage,
               let rating = message.rating {
                RatingCellView(rating: rating) { value, ratingId in
                    delegate?.onRate(value: value, ratingId: ratingId)
                }
            } else {
                if (message.rating != nil){
                    SystemMessageCellView(message: message)
                }else{
                    TextMessageCellView(message: message,
                                        replyMessage: replyMessage,
                                        onLongPress: onLongPress,
                                        onReplyMessageTapCompletion: onReplyMessageTapCompletion)
                }
            }
        case .file:
            if let file = message.file {
                if file.isImage {
                    MediaMessageCellView(message: message, replyMessage: replyMessage) {
                        delegate?.onFileTap(file)
                    } onCancelImageSendCompletion: {
                        delegate?.onCancelUpload(message)
                    } onReplyMessageTapCompletion: { messageId in
                        onReplyMessageTapCompletion?(messageId)
                    }
                } else if file.isFile {
                    FilePreviewCellView(message: message, replyMessage: replyMessage) {
                        delegate?.onFileTap(file)
                    } onCancelFileSendCompletion: {
                        delegate?.onCancelUpload(message)
                    } onReplyMessageTapCompletion: { messageId in
                        onReplyMessageTapCompletion?(messageId)
                    }
                }
            }
        case .singleChoice:
            if message.isDropDown == true {
                SingleChoicesView(message: message, displaySingleChoices: isLastMessage) { singleChoice in
                    delegate?.onSingleChoiceTap(singleChoice)
                }
            } else {
                StackedSingleChoicesView(message: message) { singleChoice in
                    delegate?.onSingleChoiceTap(singleChoice)
                }
            }
        case .card, .carousel:
            CardCellView(message: message) { action in
                delegate?.onActionTap(action)
            }
        default:
            TextMessageCellView(message: message)
        }
    }
}
