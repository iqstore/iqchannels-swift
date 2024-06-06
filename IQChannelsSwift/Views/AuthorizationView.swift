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
            Text(state.description)
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            ProgressView()
        }
    }
    
    @ViewBuilder
    private func getLogoutView() -> some View {
        let titleColor = Style.getColor(theme: Style.model?.error?.titleError?.color) ?? Color(hex: "242729")
        let titleFontSize = CGFloat(Style.model?.error?.titleError?.textSize ?? 17)
        let descriptionColor = Style.getColor(theme: Style.model?.error?.textError?.color) ?? Color(hex: "242729")
        let descriptionFontSize = CGFloat(Style.model?.error?.textError?.textSize ?? 15)
        VStack(spacing: 20) {
            if let iconErrorUrl = Style.model?.error?.iconError {
                AnimatedImage(url: iconErrorUrl)
                    .resizable()
                    .indicator(SDWebImageActivityIndicator.gray)
                    .transition(SDWebImageTransition.fade)
                    .scaledToFit()
                    .frame(width: 48, height: 48)
            } else {
                Image(name: "circle_error")
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            
            VStack(spacing: 8) {
                Text("Чат временно недоступен")
                    .foregroundColor(titleColor)
                    .font(.system(size: titleFontSize, weight: .semibold))
                
                Text("Мы уже все исправляем. Обновите\nстраницу или попробуйте позже")
                    .foregroundColor(descriptionColor)
                    .font(.system(size: descriptionFontSize))
                    .multilineTextAlignment(.center)
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
