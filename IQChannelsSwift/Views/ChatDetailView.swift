import SwiftUI

protocol ChatDetailViewDelegate: AnyObject {
    func onAttachmentTap()
    func onFileTap(_ file: IQFile)
    func onSingleChoiceTap(_ singleChoice: IQSingleChoice)
    func onActionTap(_ action: IQAction)
    func onMessageAppear(with messageId: Int)
    func onSendMessage(_ text: String)
    func onCancelUpload(_ message: IQMessage)
    func onRate(value: Int, ratingId: Int)
}

struct ChatDetailView: View {
    
    // MARK: - PROPERTIES
    @EnvironmentObject var viewModel: IQChatDetailViewModel
    
    weak var delegate: ChatDetailViewDelegate?
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ChatMessagesView(messages: viewModel.messages, delegate: delegate)
                ChatInputView(text: $viewModel.inputText,
                              messageToReply: $viewModel.messageToReply,
                              disableInput: viewModel.messages.first?.disableFreeText ?? false,
                              onAttachmentCompletion: {
                    delegate?.onAttachmentTap()
                }, onSendCompletion: {
                    delegate?.onSendMessage(viewModel.inputText)
                    viewModel.inputText = ""
                    viewModel.messageToReply = nil
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
        .animation(.easeInOut(duration: 0.25), value: viewModel.messages)
        .animation(.easeInOut(duration: 0.25), value: viewModel.typingUser)
        .animation(.bouncy, value: viewModel.isMessageCopied)
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
            
            Text("Сообщение скопировано")
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
}
