import SwiftUI

protocol ChatDetailViewDelegate: AnyObject {
    func onAttachmentTap()
    func onFileTap(_ file: IQFile, sessionToken: String)
    func onSingleChoiceTap(_ singleChoice: IQSingleChoice)
    func onActionTap(_ action: IQAction)
    func onMessageAppear(with messageId: Int)
    func onSendMessage(_ text: String)
    func onResendMessage(_ message: IQMessage)
    func onCancelUpload(_ message: IQMessage)
    func onCancelSend(_ message: IQMessage)
    func onRate(value: Int, ratingId: Int)
    func onSendPoll(value: Int?, answers: [IQRatingPollClientAnswerInput], ratingId: Int, pollId: Int)
    func onPollIgnored(ratingId: Int, pollId: Int)
}

struct ChatDetailView: View {
    
    // MARK: - PROPERTIES
    @EnvironmentObject var viewModel: IQChatDetailViewModel
    @Environment(\.colorScheme) var colorScheme
    
    weak var delegate: ChatDetailViewDelegate?
    
    var backgroundColor: Color {
        return IQStyle.getColor(theme: IQStyle.model?.chat?.background) ?? .white
    }
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ChatMessagesView(delegate: delegate)
                
                ChatInputView(text: $viewModel.inputText,
                              messageToReply: $viewModel.messageToReply,
                              selectedFiles: $viewModel.selectedFiles,
                              disableInput: viewModel.messages.first?.disableFreeText ?? false,
                              onAttachmentCompletion: {
                    delegate?.onAttachmentTap()
                }, onSendCompletion: {
                    delegate?.onSendMessage(viewModel.inputText)
                    viewModel.inputText = ""
                    viewModel.messageToReply = nil
                    viewModel.selectedFiles = nil
                })
            }
            .zIndex(0)
            
            Group {
                if viewModel.isMessageCopied {
                    getMessageCopiedOverlay()
                }
            }
            .zIndex(1)
            .opacity(viewModel.isMessageCopied ? 1 : 0)
        }
        .background(backgroundColor.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.25), value: viewModel.typingUser)
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3), value: viewModel.isMessageCopied)
        .overlay(getMessageControlOverlay())
    }
    
    // MARK: - VIEWS
    @ViewBuilder
    private func getMessageControlOverlay() -> some View {
        if viewModel.messageControlShown,
           let controlInfo = viewModel.messageControlInfo {
            MessageControlOverlayView(messageDisplayInfo: controlInfo) {
                viewModel.messageControlShown = false
                viewModel.messageControlInfo = nil
            } onActionCompletion: { controlType in
                switch controlType {
                case .copy:
                    UIPasteboard.general.string = controlInfo.message.text
                    viewModel.isMessageCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        viewModel.isMessageCopied = false
                    }
                case .reply:
                    viewModel.messageToReply = controlInfo.message
                }
            }
        }
    }
    
    @ViewBuilder
    private func getMessageCopiedOverlay() -> some View {
        HStack(spacing: 8) {
            Image(name: "status_success")
                .resizable()
                .frame(width: 20, height: 20)
            
            Text(IQLanguageTexts.model.textCopied ?? "Сообщение скопировано")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                viewModel.isMessageCopied = false
            } label: {
                Image(name: "xmark")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(8)
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 16)
        .background(Color(hex: "57B22F"))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(16)
        .transition(.move(edge: .top))
    }
    
    struct RoundedCorner: Shape {
        var radius: CGFloat = 0
        var corners: UIRectCorner = .allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }
}
