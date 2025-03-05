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
        return Style.getColor(theme: Style.model?.rating?.backgroundContainer?.color) ?? Color(hex: "F4F4F8")
    }
    var backgroundRadius: CGFloat {
        return Style.model?.rating?.backgroundContainer?.border?.borderRadius ?? 12
    }
    var backgroundBorderSize: CGFloat {
        return Style.model?.rating?.backgroundContainer?.border?.size ?? 0
    }
    var backgroundBorderColor: Color {
        return Style.getColor(theme: Style.model?.rating?.backgroundContainer?.border?.color) ?? Color(hex: "000000")
    }
    
    var titleColor: Color {
        return Style.getColor(theme: Style.model?.rating?.ratingTitle?.color) ?? Color(hex: "242729")
    }
    var titleFontSize: CGFloat {
        return CGFloat(Style.model?.rating?.ratingTitle?.textSize ?? 17)
    }
    var titleIsBold: Bool {
        return Style.model?.rating?.ratingTitle?.textStyle?.bold ?? false
    }
    var titleIsItalic: Bool {
        return Style.model?.rating?.ratingTitle?.textStyle?.italic ?? false
    }
    var titleAligment: TextAlignment {
        return stringToAlignment(stringAlignment: Style.model?.rating?.ratingTitle?.textAlign) ?? .leading
    }
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 12) {
            if #available(iOS 16.0, *) {
                Text("Удалось решить вопрос?\nОцените работу оператора")
                    .foregroundColor(titleColor)
                    .font(.system(size: titleFontSize))
                    .minimumScaleFactor(0.8)
                    .bold(titleIsBold)
                    .italic(titleIsItalic)
                    .multilineTextAlignment(titleAligment)
            } else {
                Text("Удалось решить вопрос?\nОцените работу оператора")
                    .foregroundColor(titleColor)
                    .font(.system(size: titleFontSize))
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(titleAligment)
            }
            
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
            SentRatingButton(disabled: selectedRating == nil) {
                if let selectedRating {
                    onRateConversation?(selectedRating, rating.id)
                }
            }
        }
        .frame(width: cellWidth)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(backgroundColor)
        .cornerRadius(backgroundRadius)
        .overlay(
            RoundedRectangle(cornerRadius: backgroundRadius)
                .stroke(backgroundBorderColor, lineWidth: backgroundBorderSize)
        )
    }
}
