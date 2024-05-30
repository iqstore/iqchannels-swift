import SwiftUI

struct ChatListCellView: View {
    
    // MARK: - PROPERTIES
    let chatInfoModel: IQChatItemModel
    
    // MARK: - BODY
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: chatInfoModel.info?.channelIconColor ?? "66B2B2"))
                    .frame(width: 52, height: 52)
                
                let imageName = chatInfoModel.chatType == .manager ? "user" : "chat"
                Image(name: imageName)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(chatInfoModel.info?.channelName ?? "")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: "494949"))
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                    
//                    Text("вчера, 10:38")
//                        .font(.system(size: 14))
//                        .foregroundColor(Color(hex: "969696"))
//                        .lineLimit(1)
                }
                
//                Text("Здравствуйте")
//                    .font(.system(size: 16))
//                    .foregroundColor(Color(hex: "969696"))
//                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
    }
}
