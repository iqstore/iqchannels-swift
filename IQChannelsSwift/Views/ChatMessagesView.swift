import SwiftUI

struct ChatMessagesView: View {
    
    // MARK: - PROPERTIES
    let messages: [IQMessage]
    
    weak var delegate: ChatDetailViewDelegate?
    
    @EnvironmentObject var viewModel: IQChatDetailViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var keyboardShown: Bool = false
    @State private var isScrollDownVisible: Bool = false
    
    // MARK: - BODY
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    Color.clear.frame(height: 1)
                        .id("last")
                    
                    if let typingUser = viewModel.typingUser {
                        getTypingView(user: typingUser)
                            .modifier(FlippedUpsideDown())
                    }
                    
                    ForEach(messages) { message in
                        let index = messages.firstIndex(of: message) ?? 0
                        VStack(spacing: 8) {
                            if shouldDisplayMessageDate(index) {
                                getDatePreviewView(date: message.createdDate.formatRelatively())
                            }
                            
                            let isLastMessage = message == messages.first
                            ChatMessageCellView(message: message,
                                                replyMessage: viewModel.getMessage(with: message.replyToMessageID),
                                                isGroupStart: isGroupStart(index),
                                                isLastMessage: isLastMessage,
                                                delegate: delegate,
                                                onLongPress: { messageControlInfo in
                                viewModel.showMessageControl(messageControlInfo)
                            }, onReplyToMessage: { message in
                                viewModel.messageToReply = message
                            }, onReplyMessageTapCompletion: { messageId in
                                if let id = viewModel.messages.first(where: { $0.messageID == messageId })?.id {
                                    withAnimation(.easeInOut) {
                                        proxy.scrollTo(id, anchor: .center)
                                    }
                                }
                            })
                            .onAppear {
                                delegate?.onMessageAppear(with: message.messageID)
                            }
                        }
                        .modifier(FlippedUpsideDown())
                    }
                }
                .padding([.bottom, .horizontal], 16)
                .background(GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                })
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    isScrollDownVisible = value.y < -100
                }
            }
            .clipped()
            .coordinateSpace(name: "scroll")
            .modifier(FlippedUpsideDown())
            .modifier(HideKeyboardOnDragGesture())
            .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
            .overlay(getScrollDownButton(proxy: proxy), alignment: .bottomTrailing)
            .overlay(getLoadingView())
            .onReceive(keyboardPublisher) { keyboardShown = $0 }
            .onChange(of: viewModel.scrollDown) { _ in
                withAnimation(.easeInOut) {
                    proxy.scrollTo("last", anchor: .bottom)
                }
            }
            .animation(.bouncy, value: isScrollDownVisible)
            .animation(.easeInOut, value: viewModel.isLoading)
        }
    }
    
    // MARK: - VIEWS
    @ViewBuilder
    private func getDatePreviewView(date: String) -> some View {
        let color = Style.getColor(theme: Style.model?.chat?.dateText?.color) ?? Color(hex: "919399")
        let fontSize = CGFloat(Style.model?.chat?.dateText?.textSize ?? 13)
        Text(date)
            .font(.system(size: fontSize))
            .foregroundColor(color)
            .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private func getTypingView(user: IQUser) -> some View {
        let backgroundColor = Style.getColor(theme: Style.model?.messages?.backgroundOperator) ?? Color(hex: "F4F4F8")
        let textColor = Style.getColor(theme: Style.model?.messages?.textOperator?.color) ?? Color(hex: "242729")
        let fontSize = CGFloat(Style.model?.messages?.textOperator?.textSize ?? 17)
        ZStack {
            Text("\(user.displayName ?? "") печатает...")
                .font(.system(size: fontSize))
                .foregroundColor(textColor)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(backgroundColor)
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 48)
    }
    
    @ViewBuilder
    private func getScrollDownButton(proxy: ScrollViewProxy) -> some View {
        if isScrollDownVisible {
            Button {
                withAnimation(.easeInOut) {
                    proxy.scrollTo("last", anchor: .bottom)
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(name: "chevron_down")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "E4E8ED"), lineWidth: 1))
                    
                    if !viewModel.scrollDotHidden {
                        Circle()
                            .fill(Color(hex: "DD0A34"))
                            .frame(width: 8, height: 8)
                            .padding(2)
                    }
                }
                .animation(.easeInOut, value: viewModel.scrollDotHidden)
            }
            .padding(8)
            .transition(.move(edge: .trailing))
        }
    }
    
    @ViewBuilder
    private func getLoadingView() -> some View {
        if viewModel.isLoading {
            HStack(spacing: 4) {
                Text("Загрузка...")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: - METHODS
    private func isGroupStart(_ index: Int) -> Bool {
        guard index < messages.count - 1 else { return true }
        
        let message = messages[index]
        let prev = messages[index + 1]
        return prev.isMy != message.isMy
        || (prev.userID != nil && prev.userID != message.userID)
        || ((message.createdAt ?? 0) - (prev.createdAt ?? 0)) > 60000
    }
    
    private func shouldDisplayMessageDate(_ index: Int) -> Bool {
        guard index < messages.count - 1 else { return true }
        
        let message = messages[index]
        let prev = messages[index + 1]
        let calendar = Calendar.current
        let messageDateComponents = calendar.dateComponents([.year, .month, .day], from: message.createdDate)
        let prevDateComponents = calendar.dateComponents([.year, .month, .day], from: prev.createdDate)
        
        return messageDateComponents.year != prevDateComponents.year ||
        messageDateComponents.month != prevDateComponents.month ||
        messageDateComponents.day != prevDateComponents.day
    }
}
