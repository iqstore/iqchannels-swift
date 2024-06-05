import SwiftUI

struct RatingCellView: View {
    
    // MARK: - PROPERTIES
    let rating: IQRating
    let onRateConversation: ((Int, Int) -> Void)?
    
    @State private var selectedRating: Int? = nil
    
    var starWidth: CGFloat {
        return min(36, UIScreen.screenWidth / 10)
    }
    
    var cellWidth: CGFloat {
        return starWidth * 5 + 8 * 4
    }
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 12) {
            Text("Удалось решить вопрос?\nОцените работу оператора")
                .foregroundColor(Color(hex: "242729"))
                .font(.system(size: 17))
                .minimumScaleFactor(0.8)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                ForEach(1..<6) { i in
                    Button {
                        selectedRating = i
                    } label: {
                        let imageName = (i <= selectedRating ?? 0) ? "star_on" : "star_off"
                        Image(name: imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: starWidth, height: starWidth)
                    }
                }
            }
            
            Button {
                if let selectedRating {
                    onRateConversation?(selectedRating, rating.id)
                }
            } label: {
                Text("Отправить")
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .frame(height: 32)
                    .frame(maxWidth: .infinity)
                    .background(selectedRating == nil ? Color(hex: "B7B7CA") : Color(hex: "DD0A34"))
                    .cornerRadius(8)
            }
            .disabled(selectedRating == nil)
        }
        .frame(width: cellWidth)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(hex: "F4F4F8"))
        .cornerRadius(12)
    }
}
