import SwiftUI

struct AuthorizationView: View {
    
    // MARK: - PROPERTIES
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
            Text(state.description ?? "")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            ProgressView()
        }
    }
    
    @ViewBuilder
    private func getLogoutView() -> some View {
        VStack(spacing: 20) {
            Image(name: "circle_error")
                .resizable()
                .frame(width: 48, height: 48)
            
            VStack(spacing: 8) {
                Text("Чат временно недоступен")
                    .font(.system(size: 17, weight: .semibold))
                
                Text("Мы уже все исправляем. Обновите\nстраницу или попробуйте позже")
                    .font(.system(size: 15))
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
