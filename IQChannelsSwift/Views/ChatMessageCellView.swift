import SwiftUI
import SDWebImageSwiftUI

struct ChatMessageCellView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let message: IQMessage
    let replyMessage: IQMessage?
    let isGroupStart: Bool
    let isLastMessage: Bool
    
    weak var delegate: ChatDetailViewDelegate?
    
    let onLongPress: ((MessageControlInfo) -> Void)?
    let onReplyToMessage: ((IQMessage) -> Void)?
    let onReplyMessageTapCompletion: ((Int) -> Void)?
    let onErrorTap: ((IQMessage) -> Void)?
    
    @State private var dragAmountX: CGFloat = 0
    @State private var isMenuVisible = false
    
    var backgroundColor: Color {
        return Style.getColor(theme: Style.model?.chat?.background) ?? Color(hex: "919399")
    }
    
    var senderTextColor: Color {
        return Style.getColor(theme: Style.model?.messages?.textUp?.color) ?? Color(hex: "919399")
    }
    
    var senderFontSize: CGFloat {
        return CGFloat(Style.model?.messages?.textUp?.textSize ?? 13)
    }
    
    // MARK: - BODY
    var body: some View {
        let isSender = message.isMy
        let isSystem = message.isSystem
        
        if !isSystem {
            ZStack(alignment: .trailing) {
                getReplyView()
                    .opacity(-dragAmountX / 56)
                    .offset(x: 56)
                
                HStack(alignment: .bottom, spacing: 8) {
                    if !isSender {
                        getAvatarView(avatarURL: message.user?.avatarURL,
                                      userDisplayName: message.senderName)
                        .opacity(isGroupStart ? 1 : 0)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if !isSender,
                           isGroupStart {
                            Text(message.senderName)
                                .font(.system(size: senderFontSize))
                                .foregroundColor(senderTextColor)
                                .padding(.leading, 12)
                        }
                        
                        HStack(alignment: .bottom){
                            MessageCellBubbleView(message: message,
                                                  replyMessage: replyMessage,
                                                  isLastMessage: isLastMessage,
                                                  onLongPress: onLongPress,
                                                  onReplyMessageTapCompletion: onReplyMessageTapCompletion,
                                                  delegate: delegate)
                            if(message.error){
                                getErrorView()
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: isSender ? .trailing : .leading)
            .padding(isSender ? .leading : .trailing, 48)
            .offset(x: dragAmountX)
            .animation(.bouncy, value: dragAmountX)
            .background(Color(white: 1, opacity: 0.000001))
            .gesture(
                message.isReply ?
                    DragGesture(minimumDistance: 25, coordinateSpace: .local)
                        .onChanged { dragValue in
                            if dragValue.translation.width < 0,
                               dragValue.translation.width > -(UIScreen.main.bounds.width / 3) {
                                dragAmountX = dragValue.translation.width
                            }
                        }
                        .onEnded { dragValue in
                            if dragValue.translation.width < -60 {
                                triggerHapticFeedback(style: .rigid)
                                onReplyToMessage?(message)
                            }
                            dragAmountX = 0
                        }
                : nil
            )
        } else{
            SystemMessageCellView(message: message)
        }
            
    }
    
    // MARK: - VIEWS
    @ViewBuilder
    private func getAvatarView(avatarURL: URL?, userDisplayName: String) -> some View {
        ZStack {
            Color.paletteColorFromString(string: userDisplayName)
            
            if let avatarURL {
                AnimatedImage(url: avatarURL)
                    .resizable()
                    .indicator(SDWebImageActivityIndicator.gray)
                    .transition(SDWebImageTransition.fade)
                    .scaledToFill()
            } else {
                let initials = userDisplayName.prefix(1)
                Text(initials)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }
    
    @ViewBuilder
    private func getReplyView() -> some View {
        Image(name: "reply")
            .resizable()
            .scaledToFill()
            .frame(width: 16, height: 16)
            .padding(8)
            .background(Color(hex: "F4F4F8"))
            .clipShape(Circle())
    }
    
    
    @ViewBuilder
    private func getErrorView() -> some View {
        Button(action: {
            onErrorTap?(message)
        }) {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 30, height: 30)

                Text("!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
