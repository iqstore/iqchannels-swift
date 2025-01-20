import SwiftUI

struct MessageStatusView: View {
    
    // MARK: - PROPERTIES
    private let message: IQMessage
    private let isSender: Bool
    private let withBackground: Bool
    private let backgroundColor: Color
    
    @State private var showMessageLoading: Bool = false
    
    var textColor: Color {
        if(message.isMy){
            return Style.getColor(theme: Style.model?.messages?.textClient?.color) ?? Color(hex: "919399")
        }else{
            return Style.getColor(theme: Style.model?.messages?.textOperator?.color) ?? Color(hex: "919399")
        }
    }
    
    var fontSize: CGFloat {
        if(message.isMy){
            return CGFloat(Style.model?.messages?.textClient?.textSize ?? 13)
        }else{
            return CGFloat(Style.model?.messages?.textOperator?.textSize ?? 13)
        }
    }
    
    // MARK: - INIT
    init(message: IQMessage,
         withBackground: Bool = false) {
        self.message = message
        self.isSender = message.isMy
        self.withBackground = withBackground
        self.backgroundColor = Color(hex: "242729").opacity(0.7)
    }
    
    // MARK: - BODY
    var body: some View {
        if withBackground {
            getStatusView()
                .padding(.vertical, 2)
                .padding(.horizontal, 4)
                .background(backgroundColor)
                .cornerRadius(.infinity)
        } else {
            getStatusView()
        }
    }
    
    @ViewBuilder
    private func getStatusView() -> some View {
        HStack(spacing: 2) {
            Text(message.createdDate.formatToTime())
                .foregroundColor(textColor)
                .font(.system(size: fontSize))
                .fixedSize(horizontal: true, vertical: false)
            
            if isSender {
                if message.isLoading {
                    Image(name: "loading")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(textColor)
                        .frame(width: 12, height: 12)
                        .rotationEffect(Angle(degrees: showMessageLoading ? 360 : 0.0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: showMessageLoading)
                        .onAppear { self.showMessageLoading = true }
                } else {
                    let imageName: String = (message.isRead ?? false) ? "double_checkmark" : "single_checkmark"
                    Image(name: imageName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(textColor)
                        .frame(width: 12, height: 16)
                }
            }
        }
    }
}
