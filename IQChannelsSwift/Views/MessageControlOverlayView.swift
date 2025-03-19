import SwiftUI

struct MessageControlOverlayView: View {
    
    // MARK: - PROPERTIES
    private let messageDisplayInfo: MessageControlInfo
    private let onBackgroundTap: (() -> Void)
    private let onActionCompletion: ((MessageControlType) -> Void)?
    
    @State private var popIn = false
    @State private var willPopOut = false
    
    private let screenHeight: CGFloat = UIScreen.screenHeight
    private let screenWidth: CGFloat = UIScreen.screenWidth
    
    private var popInAnimation: Animation {
        .spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2)
    }
    
    private var messageContainerHeight: CGFloat {
        let maxAllowed = screenHeight / 2
        let containerHeight = messageDisplayInfo.frame.height
        return containerHeight > maxAllowed ? maxAllowed : containerHeight
    }
    
    private var messageContainerWidth: CGFloat {
        return messageDisplayInfo.frame.width
    }
    
    private var messageActionsHeight: CGFloat {
        return controlItemHeight * CGFloat(messageDisplayInfo.controlActions.count)
    }
    
    private var messageActionsWidth: CGFloat {
        return UIScreen.screenWidth / 2
    }
    
    private let controlItemHeight: CGFloat = 40
    
    // MARK: - INIT
    init(messageDisplayInfo: MessageControlInfo,
         onBackgroundTap: @escaping (() -> Void),
         onActionCompletion: ((MessageControlType) -> Void)? = nil) {
        self.messageDisplayInfo = messageDisplayInfo
        self.onBackgroundTap = onBackgroundTap
        self.onActionCompletion = onActionCompletion
    }
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            ZStack {
                if let snapshot = messageDisplayInfo.currentSnapshot {
                    Image(uiImage: snapshot)
                        .overlay(Color.black.opacity(!popIn ? 0 : 0.1))
                        .blur(radius: !popIn ? 0 : 4)
                } else {
                    Color.white
                }
            }
            .transition(.opacity)
            .onTapGesture {
                dismissControlOverlay()
            }
            .ignoresSafeArea()
            
            GeometryReader { proxy in
                let frame = proxy.frame(in: .local)
                let height = frame.height
                let width = frame.width
                Color.clear.preference(key: HeightPreferenceKey.self, value: height)
                Color.clear.preference(key: WidthPreferenceKey.self, value: width)
                
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        if messageDisplayInfo.frame.height > messageContainerHeight {
                            ScrollView {
                                TextMessageCellView(message: messageDisplayInfo.message, 
                                                    replyMessage: messageDisplayInfo.replyMessage)
                            }
                        } else {
                            TextMessageCellView(message: messageDisplayInfo.message,
                                                replyMessage: messageDisplayInfo.replyMessage)
                        }
                    }
                    .scaleEffect(popIn || willPopOut ? 1 : 0.95)
                    .frame(
                        width: messageContainerWidth,
                        height: messageContainerHeight
                    )
                    
                    ControlActionsView(controlItemHeight: controlItemHeight) { type in
                        dismissControlOverlay {
                            onActionCompletion?(type)
                        }
                    }
                        .frame(width: messageActionsWidth,
                               height: messageActionsHeight)
                        .offset(
                            x: getControlActionsOffsetX(),
                            y: getControlActionsOffsetY()
                        )
                        .opacity(willPopOut ? 0 : 1)
                        .scaleEffect(popIn ? 1 : (willPopOut ? 0.4 : 0))
                }
                .offset(x: getMessageOffsetX(),
                        y: getMessageOffsetY())
            }
        }
        .ignoresSafeArea()
        .animation(willPopOut ? .easeInOut : popInAnimation, value: popIn)
        .onAppear {
            popIn = true
        }
    }
    
    // MARK: - METHODS
    private func dismissControlOverlay(completion: (() -> Void)? = nil) {
        withAnimation {
            willPopOut = true
            popIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onBackgroundTap()
            completion?()
        }
    }
    
    private func getMessageOffsetX() -> CGFloat {
        return messageDisplayInfo.frame.origin.x
    }
    
    private func getMessageOffsetY() -> CGFloat {
        var originY = messageDisplayInfo.frame.origin.y
        
        if popIn {
            let minOrigin: CGFloat = 64
            let maxOrigin: CGFloat = screenHeight - messageContainerHeight - messageActionsHeight - 8 - 64
            if originY < minOrigin {
                originY = minOrigin
            } else if originY > maxOrigin {
                originY = maxOrigin
            }
        }
        
        return originY
    }
    
    private func getControlActionsOffsetX() -> CGFloat {
        let messageWidth = messageDisplayInfo.frame.width
        let message = messageDisplayInfo.message
        
        if message.isMy ?? false {
            return messageWidth - messageActionsWidth
        } else {
            return 0
        }
    }
    
    private func getControlActionsOffsetY() -> CGFloat {
        if popIn {
            return 0
        } else {
            return -(messageActionsHeight + 8 + (messageContainerHeight / 2))
        }
    }
}

enum MessageControlType: Identifiable {
    case copy
    case reply
    
    var id: Int {
        switch self {
        case .copy: return 1
        case .reply: return 2
        }
    }
    
    var title: String {
        switch self {
        case .copy: return "Копировать"
        case .reply: return "Ответить"
        }
    }
    
    var image: Image {
        switch self {
        case .copy: return Image(systemName: "doc.on.doc")
        case .reply: return Image(systemName: "arrowshape.turn.up.left")
        }
    }
}

struct ControlActionsView: View {
    
    // MARK: - PROPERTIES
    let controlItemHeight: CGFloat
    let onActionCompletion: ((MessageControlType) -> Void)?
    
    private let types: [MessageControlType] = [.copy, .reply]
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            ForEach(types) { type in
                Button {
                    onActionCompletion?(type)
                } label: {
                    HStack {
                        Text(type.title)
                            .foregroundColor(Color(hex: "242729"))
                            .font(.system(size: 14))
                        
                        Spacer()
                        
                        type.image
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(Color(hex: "242729"))
                            .frame(width: 16, height: 16)
                    }
                    .frame(height: controlItemHeight)
                    .padding(.horizontal, 12)
                }
                
                if type != types.last {
                    Divider()
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
    }
}
