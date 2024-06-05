import SwiftUI
import SDWebImageSwiftUI

struct CardCellView: View {
    
    // MARK: - PROPERTIES
    let message: IQMessage
    let onActionTapCompletion: ((IQAction) -> Void)?
    var cellWidth: CGFloat {
        return UIScreen.screenWidth / 2
    }
    
    // MARK: - BODY
    var body: some View {
        VStack {
            if let imageURL = message.file?.url {
                AnimatedImage(url: imageURL)
                    .resizable()
                    .indicator(SDWebImageActivityIndicator.gray)
                    .transition(SDWebImageTransition.fade)
                    .scaledToFit()
                    .frame(width: cellWidth - 32, height: cellWidth - 32)
            }
            if let actions = message.actions {
                VStack(spacing: -1.5) {
                    ForEach(actions) { action in
                        Button {
                            onActionTapCompletion?(action)
                        } label: {
                            Text(action.title ?? "")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                                .frame(height: 32)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "E3E3E3"))
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .inset(by: 1)
                                        .stroke(.black, lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
        .frame(width: cellWidth)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(hex: "F4F4F8"))
        .cornerRadius(12)
    }
}
