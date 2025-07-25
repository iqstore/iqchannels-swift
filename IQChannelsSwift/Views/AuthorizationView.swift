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
            ProgressView()
        }
    }
    
    @ViewBuilder
    private func getLogoutView() -> some View {
        let titleColor = IQStyle.getColor(theme: IQStyle.model?.error?.titleError?.color) ?? Color(hex: "242729")
        let titleFontSize = CGFloat(IQStyle.model?.error?.titleError?.textSize ?? 17)
        let titleIsBold = IQStyle.model?.error?.titleError?.textStyle?.bold ?? false
        let titleIsItalic = IQStyle.model?.error?.titleError?.textStyle?.italic ?? false
        let titleAlignment = stringToAlignment(stringAlignment: IQStyle.model?.error?.titleError?.textAlign) ?? .leading
        
        let descriptionColor = IQStyle.getColor(theme: IQStyle.model?.error?.textError?.color) ?? Color(hex: "242729")
        let descriptionFontSize = CGFloat(IQStyle.model?.error?.textError?.textSize ?? 15)
        let descriptionIsBold = IQStyle.model?.error?.textError?.textStyle?.bold ?? false
        let descriptionIsItalic = IQStyle.model?.error?.textError?.textStyle?.italic ?? false
        let descriptionAlignment = stringToAlignment(stringAlignment: IQStyle.model?.error?.textError?.textAlign) ?? .leading
        
        VStack(spacing: 20) {
            AnimatedImage(url: IQStyle.model?.error?.iconError, 
                          placeholderImage: UIImage(name: "circle_error"))
                .resizable()
                .indicator(SDWebImageActivityIndicator.gray)
                .transition(SDWebImageTransition.fade)
                .scaledToFit()
                .frame(width: 48, height: 48)
            
            VStack(spacing: 8) {
                if #available(iOS 16.0, *) {
                    Text(IQLanguageTexts.model.titleError ?? "Чат временно недоступен")
                        .foregroundColor(titleColor)
                        .font(.system(size: titleFontSize, weight: .semibold))
                        .bold(titleIsBold)
                        .italic(titleIsItalic)
                        .multilineTextAlignment(titleAlignment)
                } else {
                    Text(IQLanguageTexts.model.titleError ?? "Чат временно недоступен")
                        .foregroundColor(titleColor)
                        .font(.system(size: titleFontSize, weight: .semibold))
                        .multilineTextAlignment(titleAlignment)
                }
                
                if #available(iOS 16.0, *) {
                    Text(IQLanguageTexts.model.textError ?? "Мы уже все исправляем. Обновите\nстраницу или попробуйте позже")
                        .foregroundColor(descriptionColor)
                        .font(.system(size: descriptionFontSize))
                        .multilineTextAlignment(.center)
                        .bold(descriptionIsBold)
                        .italic(descriptionIsItalic)
                        .multilineTextAlignment(descriptionAlignment)
                } else {
                    Text(IQLanguageTexts.model.textError ?? "Мы уже все исправляем. Обновите\nстраницу или попробуйте позже")
                        .foregroundColor(descriptionColor)
                        .font(.system(size: descriptionFontSize))
                        .multilineTextAlignment(.center)
                        .multilineTextAlignment(descriptionAlignment)
                }
            }
            
            Button {
                onDismissChat?()
            } label: {
                Text(IQLanguageTexts.model.buttonError ?? "Вернуться")
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
