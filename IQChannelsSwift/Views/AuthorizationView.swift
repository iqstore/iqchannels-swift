import SwiftUI
import SDWebImageSwiftUI

struct AuthorizationView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let state: IQChannelsState
    let onDismissChat: (() -> Void)?
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            switch state {
            case .loggedOut:
                getLogoutView()
            case .awaitingNetwork:
                getLoadingView()
            case .authenticating:
                getLoadingView()
            case .authenticated:
                EmptyView()
            }
        }
    }
    
    // MARK: - VIEWS
    @ViewBuilder
    private func getLoadingView() -> some View {
        HStack(spacing: 4) {
//            Text(state.description)
//                .foregroundColor(.gray)
//                .font(.system(size: 16))
            
            ProgressView()
        }
    }
    
    @ViewBuilder
    private func getLogoutView() -> some View {
        let titleColor = Style.getColor(theme: Style.model?.error?.titleError?.color) ?? Color(hex: "242729")
        let titleFontSize = CGFloat(Style.model?.error?.titleError?.textSize ?? 17)
        let titleIsBold = Style.model?.error?.titleError?.textStyle?.bold ?? false
        let titleIsItalic = Style.model?.error?.titleError?.textStyle?.italic ?? false
        let titleAlignment = stringToAlignment(stringAlignment: Style.model?.error?.titleError?.textAlign) ?? .leading
        
        let descriptionColor = Style.getColor(theme: Style.model?.error?.textError?.color) ?? Color(hex: "242729")
        let descriptionFontSize = CGFloat(Style.model?.error?.textError?.textSize ?? 15)
        let descriptionIsBold = Style.model?.error?.textError?.textStyle?.bold ?? false
        let descriptionIsItalic = Style.model?.error?.textError?.textStyle?.italic ?? false
        let descriptionAlignment = stringToAlignment(stringAlignment: Style.model?.error?.textError?.textAlign) ?? .leading
        
        VStack(spacing: 20) {
            AnimatedImage(url: Style.model?.error?.iconError, 
                          placeholderImage: UIImage(name: "circle_error"))
                .resizable()
                .indicator(SDWebImageActivityIndicator.gray)
                .transition(SDWebImageTransition.fade)
                .scaledToFit()
                .frame(width: 48, height: 48)
            
            VStack(spacing: 8) {
                if #available(iOS 16.0, *) {
                    Text("Чат временно недоступен")
                        .foregroundColor(titleColor)
                        .font(.system(size: titleFontSize, weight: .semibold))
                        .bold(titleIsBold)
                        .italic(titleIsItalic)
                        .multilineTextAlignment(titleAlignment)
                } else {
                    Text("Чат временно недоступен")
                        .foregroundColor(titleColor)
                        .font(.system(size: titleFontSize, weight: .semibold))
                        .multilineTextAlignment(titleAlignment)
                }
                
                if #available(iOS 16.0, *) {
                    Text("Мы уже все исправляем. Обновите\nстраницу или попробуйте позже")
                        .foregroundColor(descriptionColor)
                        .font(.system(size: descriptionFontSize))
                        .multilineTextAlignment(.center)
                        .bold(descriptionIsBold)
                        .italic(descriptionIsItalic)
                        .multilineTextAlignment(descriptionAlignment)
                } else {
                    Text("Мы уже все исправляем. Обновите\nстраницу или попробуйте позже")
                        .foregroundColor(descriptionColor)
                        .font(.system(size: descriptionFontSize))
                        .multilineTextAlignment(.center)
                        .multilineTextAlignment(descriptionAlignment)
                }
            }
            
            Button {
                onDismissChat?()
            } label: {
                Text("Вернуться")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(hex: "F4F4F8"))
                    .cornerRadius(12)
            }
        }
    }
}
