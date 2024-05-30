import SwiftUI

struct ChatListView: View {
    
    // MARK: - PROPERTIES
    @ObservedObject var viewModel: IQChatListViewModel

    let output: IQChannelsManagerListOutput
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            if viewModel.state == .authenticated {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.chatsInfo) { chatInfo in
                            Button {
                                output.listController(didSelectChat: chatInfo)
                            } label: {
                                ChatListCellView(chatInfoModel: chatInfo)
                            }
                        }
                    }
                }
            } else {
                AuthorizationView(state: viewModel.state) {
                    output.listControllerDismissChat()
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .animation(.easeIn(duration: 0.25), value: viewModel.chatsInfo)
        .animation(.easeInOut(duration: 0.25), value: viewModel.state)
    }
}
