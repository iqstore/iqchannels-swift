import SwiftUI

struct StackedSingleChoicesView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let message: IQMessage
    let onSingleChoiceTapCompletion: ((IQSingleChoice) -> Void)?
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: message.isMy ? .trailing : .leading, spacing: 4) {
            TextMessageCellView(message: message)
            
            if let singleChoices = message.singleChoices {
                ForEach(singleChoices) { singleChoice in
                    let backgroundColor = Style.getColor(theme: Style.model?.singleChoice?.backgroundButton) ?? Color(hex: "AFB8BE")
                    let textColor = Style.getColor(theme: Style.model?.singleChoice?.textButton?.color) ?? Color.white
                    let fontSize = CGFloat(Style.model?.singleChoice?.textButton?.textSize ?? 12)
                    let borderColor = Style.getColor(theme: Style.model?.singleChoice?.borderButton?.color) ?? Color.clear
                    let lineWidth = CGFloat(Style.model?.singleChoice?.borderButton?.size ?? 0)
                    let borderRadius = CGFloat(Style.model?.singleChoice?.borderButton?.borderRadius ?? 4)
                    Button {
                        onSingleChoiceTapCompletion?(singleChoice)
                    } label: {
                        Text(singleChoice.title ?? "")
                            .font(.system(size: fontSize))
                            .foregroundColor(textColor)
                            .frame(height: 32)
                            .frame(maxWidth: .infinity)
                            .background(backgroundColor)
                            .cornerRadius(borderRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: borderRadius)
                                    .inset(by: lineWidth / 2)
                                    .stroke(borderColor, lineWidth: lineWidth)
                            )
                    }
                }
            }
        }
    }
}
