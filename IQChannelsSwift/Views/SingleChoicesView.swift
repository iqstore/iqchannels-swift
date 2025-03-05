import SwiftUI

struct SingleChoicesView: View {
    
    // MARK: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    let message: IQMessage
    let displaySingleChoices: Bool
    let onSingleChoiceTapCompletion: ((IQSingleChoice) -> Void)?
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextMessageCellView(message: message)
            
            if displaySingleChoices,
               let singleChoices = message.singleChoices {
                FlexibleView(
                    availableWidth: UIScreen.screenWidth - 100,
                    data: singleChoices,
                    spacing: 4,
                    alignment: .leading
                ) { singleChoice in
                    Button {
                        onSingleChoiceTapCompletion?(singleChoice)
                    } label: {
                        let textColor = Style.getColor(theme: Style.model?.singleChoice?.textIVR?.color) ?? Color(hex: "96BB5D")
                        let fontSize = CGFloat(Style.model?.singleChoice?.textIVR?.textSize ?? 12)
                        let isBold = Style.model?.singleChoice?.textIVR?.textStyle?.bold ?? false
                        let isItalic = Style.model?.singleChoice?.textIVR?.textStyle?.italic ?? false
                        let alignment = stringToAlignment(stringAlignment: Style.model?.singleChoice?.textIVR?.textAlign) ?? .center
                        let textAlignments: [TextAlignment: Alignment] = [
                            .leading: Alignment.leading,
                            .center: Alignment.center,
                            .trailing: Alignment.trailing
                        ]
                        
                        let borderColor = Style.getColor(theme: Style.model?.singleChoice?.borderIVR?.color) ?? Color(hex: "96BB5D")
                        let lineWidth = CGFloat(Style.model?.singleChoice?.borderIVR?.size ?? 1)
                        let borderRadius = CGFloat(Style.model?.singleChoice?.borderIVR?.borderRadius ?? 8)
                        let backgroundColor = Style.getColor(theme: Style.model?.singleChoice?.backgroundIVR) ?? Color.clear
                        
                        if #available(iOS 16.0, *) {
                            Text(singleChoice.title ?? "")
                                .font(.system(size: fontSize))
                                .foregroundColor(textColor)
                                .frame(height: 32)
                                .frame(maxWidth: .infinity, alignment: textAlignments[alignment] ?? Alignment.center)
                                .padding(.horizontal, 4)
                                .background(backgroundColor)
                                .cornerRadius(borderRadius)
                                .bold(isBold)
                                .italic(isItalic)
                                .overlay(
                                    RoundedRectangle(cornerRadius: borderRadius)
                                        .stroke(borderColor, lineWidth: lineWidth)
                                )
                        } else {
                            Text(singleChoice.title ?? "")
                                .font(.system(size: fontSize))
                                .foregroundColor(textColor)
                                .frame(height: 32)
                                .frame(maxWidth: .infinity, alignment: textAlignments[alignment] ?? Alignment.center)
                                .padding(.horizontal, 4)
                                .background(backgroundColor)
                                .cornerRadius(borderRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: borderRadius)
                                        .stroke(borderColor, lineWidth: lineWidth)
                                )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - FLEXIBLE VIEW
struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    var body : some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}
