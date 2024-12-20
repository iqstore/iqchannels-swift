import SwiftUI
import SDWebImageSwiftUI

struct RatingCellView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let rating: IQRating
    let onRateConversation: ((Int, Int) -> Void)?
    
    @State private var selectedRating: Int? = nil
    
    var cellWidth: CGFloat {
        return UIScreen.screenWidth - 50
    }
    
    var starWidth: CGFloat {
        return min(50, (cellWidth - 50) / 5)
    }
    
    var backgroundColor: Color {
        return Style.getColor(theme: Style.model?.rating?.backgroundContainer) ?? Color(hex: "F4F4F8")
    }
    
    var textColor: Color {
        return Style.getColor(theme: Style.model?.rating?.text?.color) ?? Color(hex: "242729")
    }
    
    var textFontSize: CGFloat {
        return CGFloat(Style.model?.rating?.text?.textSize ?? 17)
    }
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 12) {
            Text("Удалось решить вопрос?\nОцените работу оператора")
                .foregroundColor(textColor)
                .font(.system(size: textFontSize))
                .minimumScaleFactor(0.8)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                ForEach(1..<6) { i in
                    Button {
                        selectedRating = i
                    } label: {
                        if i <= selectedRating ?? 0 {
                            if let fullStarUrl = Style.model?.rating?.fullStar {
                                AnimatedImage(url: fullStarUrl)
                                    .resizable()
                                    .indicator(SDWebImageActivityIndicator.gray)
                                    .transition(SDWebImageTransition.fade)
                                    .scaledToFit()
                                    .frame(width: starWidth, height: starWidth)
                            } else {
                                Image(name: "star_on")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: starWidth, height: starWidth)
                            }
                        } else {
                            if let emptyStarUrl = Style.model?.rating?.emptyStar {
                                AnimatedImage(url: emptyStarUrl)
                                    .resizable()
                                    .indicator(SDWebImageActivityIndicator.gray)
                                    .transition(SDWebImageTransition.fade)
                                    .scaledToFit()
                                    .frame(width: starWidth, height: starWidth)
                            } else {
                                Image(name: "star_off")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: starWidth, height: starWidth)
                            }
                        }
                    }
                }
            }
            
            Button {
                if let selectedRating {
                    onRateConversation?(selectedRating, rating.id)
                }
            } label: {
                let enabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textEnabled?.color) ?? Color.white
                let disabledRatingTextColor = Style.getColor(theme: Style.model?.rating?.sentRating?.textDisabled?.color) ?? Color.white
                let enabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textEnabled?.textSize ?? 15)
                let disabledRatingFontSize = CGFloat(Style.model?.rating?.sentRating?.textDisabled?.textSize ?? 15)
                let enabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.colorEnabled) ?? Color(hex: "DD0A34")
                let disabledRatingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.colorDisabled) ?? Color(hex: "B7B7CA")
                Text("Отправить")
                    .foregroundColor(selectedRating == nil ? disabledRatingTextColor : enabledRatingTextColor)
                    .font(.system(size: selectedRating == nil ? disabledRatingFontSize : enabledRatingFontSize))
                    .frame(height: 32)
                    .frame(maxWidth: .infinity)
                    .background(selectedRating == nil ? disabledRatingBackgroundColor : enabledRatingBackgroundColor)
                    .cornerRadius(8)
            }
            .disabled(selectedRating == nil)
        }
        .frame(width: cellWidth)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}
