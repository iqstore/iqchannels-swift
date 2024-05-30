import SwiftUI

struct MessageStatusView: View {
    
    // MARK: - PROPERTIES
    private let message: IQMessage
    private let isSender: Bool
    private let tintColor: Color
    private let withBackground: Bool
    private let backgroundColor: Color
    
    @State private var showMessageLoading: Bool = false
    
    // MARK: - INIT
    init(message: IQMessage, withBackground: Bool = false) {
        self.message = message
        self.isSender = message.isMy ?? false
        self.tintColor = Color(hex: "919399")
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
                .foregroundColor(tintColor)
                .font(.system(size: 13))
                .fixedSize(horizontal: true, vertical: false)
            
            if isSender {
                if message.isLoading {
                    Image(name: "loading")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(tintColor)
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
                        .foregroundColor(tintColor)
                        .frame(width: 12, height: 16)
                }
            }
        }
    }
}
