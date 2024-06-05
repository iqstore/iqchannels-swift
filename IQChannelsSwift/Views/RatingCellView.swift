import SwiftUI
import SDWebImageSwiftUI

struct RatingCellView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let rating: IQRating
    let onRateConversation: ((Int, Int) -> Void)?
    
    @State private var selectedRating: Int? = nil
    
    var starWidth: CGFloat {
        return min(36, UIScreen.screenWidth / 10)
    }
    
    var cellWidth: CGFloat {
        return starWidth * 5 + 8 * 4
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
                let ratingTextColor = Style.getColor(theme: Style.model?.rating?.textRating?.color) ?? Color.white
                let ratingFontSize = CGFloat(Style.model?.rating?.textRating?.textSize ?? 15)
                let ratingBackgroundColor = Style.getColor(theme: Style.model?.rating?.sentRating?.color) ?? Color(hex: "DD0A34")
                let borderRadius = CGFloat(Style.model?.rating?.sentRating?.borderRadius ?? 8)
                Text("Отправить")
                    .foregroundColor(ratingTextColor)
                    .font(.system(size: ratingFontSize))
                    .frame(height: 32)
                    .frame(maxWidth: .infinity)
                    .background(selectedRating == nil ? Color(hex: "B7B7CA") : ratingBackgroundColor)
                    .cornerRadius(borderRadius)
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
