import SwiftUI

struct StackedSingleChoicesView: View {
    
    // MARK: - PROPERTIES
    let message: IQMessage
    let onSingleChoiceTapCompletion: ((IQSingleChoice) -> Void)?
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: message.isMy ?? false ? .trailing : .leading, spacing: 4) {
            TextMessageCellView(message: message)
            
            if let singleChoices = message.singleChoices {
                ForEach(singleChoices) { singleChoice in
                    Button {
                        onSingleChoiceTapCompletion?(singleChoice)
                    } label: {
                        Text(singleChoice.title ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .frame(height: 32)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "AFB8BE"))
                            .cornerRadius(4)
                    }
                }
            }
        }
    }
}
