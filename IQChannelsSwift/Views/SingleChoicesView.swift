import SwiftUI

struct SingleChoicesView: View {
    
    // MARK: - PROPERTIES
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
                        Text(singleChoice.title ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "96BB5D"))
                            .frame(height: 32)
                            .padding(.horizontal, 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .inset(by: 1)
                                    .stroke(Color(hex: "96BB5D"), lineWidth: 1)
                            )
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
