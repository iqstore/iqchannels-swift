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
            return Style.getColor(theme: Style.model?.messages?.textTimeClient?.color) ?? Color(hex: "919399")
        }else{
            return Style.getColor(theme: Style.model?.messages?.textTimeOperator?.color) ?? Color(hex: "919399")
        }
    }
    var fontSize: CGFloat {
        if(message.isMy){
            return CGFloat(Style.model?.messages?.textTimeClient?.textSize ?? 13)
        }else{
            return CGFloat(Style.model?.messages?.textTimeOperator?.textSize ?? 13)
        }
    }
    var alignment: TextAlignment {
        if(message.isMy){
            return stringToAlignment(stringAlignment: Style.model?.messages?.textTimeClient?.textAlign) ?? .leading
        }else{
            return stringToAlignment(stringAlignment: Style.model?.messages?.textTimeOperator?.textAlign) ?? .leading
        }
    }
    var isBold: Bool {
        if(message.isMy){
            return Style.model?.messages?.textTimeClient?.textStyle?.bold ?? false
        }else{
            return Style.model?.messages?.textTimeOperator?.textStyle?.bold ?? false
        }
    }
    var isItalic: Bool {
        if(message.isMy){
            return Style.model?.messages?.textTimeClient?.textStyle?.italic ?? false
        }else{
            return Style.model?.messages?.textTimeOperator?.textStyle?.italic ?? false
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
            if #available(iOS 16.0, *) {
                Text(message.createdDate.formatToTime())
                    .foregroundColor(textColor)
                    .font(.system(size: fontSize))
                    .fixedSize(horizontal: true, vertical: false)
                    .bold(isBold)
                    .italic(isItalic)
                    .multilineTextAlignment(alignment)
            } else {
                Text(message.createdDate.formatToTime())
                    .foregroundColor(textColor)
                    .font(.system(size: fontSize))
                    .fixedSize(horizontal: true, vertical: false)
                    .multilineTextAlignment(alignment)
            }
            
            if isSender {
                if message.isLoading {
                    if !message.error {
                        Image(name: "loading")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(textColor)
                            .frame(width: 12, height: 12)
                            .rotationEffect(Angle(degrees: showMessageLoading ? 360 : 0.0))
                            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: showMessageLoading)
                            .onAppear { self.showMessageLoading = true }
                    }
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
