import SwiftUI

struct ComposerInputView: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var height: CGFloat
    
    var currentHeight: CGFloat
    
    func makeUIView(context: Context) -> InputTextView {
        let inputTextView: InputTextView
        if #available(iOS 16.0, *) {
            inputTextView = InputTextView(usingTextLayoutManager: false)
        } else {
            inputTextView = InputTextView()
        }
        context.coordinator.textView = inputTextView
        inputTextView.delegate = context.coordinator
        inputTextView.layoutManager.delegate = context.coordinator
        inputTextView.contentInsetAdjustmentBehavior = .never
        inputTextView.setContentCompressionResistancePriority(.defaultLow + 10, for: .horizontal)
        return inputTextView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            if uiView.markedTextRange == nil {
                if uiView.text != text {
                    uiView.text = text
                }
                context.coordinator.updateHeight(uiView)
                if uiView.frame.size.height != currentHeight {
                    uiView.frame.size = CGSize(
                        width: uiView.frame.size.width,
                        height: currentHeight
                    )
                }
                if uiView.contentSize.height != height {
                    uiView.contentSize.height = height
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return ComposerInputView.Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
        
        weak var textView: InputTextView?
        
        var parent: ComposerInputView
        
        init(parent: ComposerInputView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            updateHeight(textView)
        }

        func updateHeight(_ textView: UITextView) {
            var height = textView.sizeThatFits(textView.bounds.size).height
            if height < CustomTextAreaConfig.minHeight {
                height = CustomTextAreaConfig.minHeight
            }
            if parent.height != height {
                parent.height = height
            }
        }

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            let newMessageLength = textView.text.count + (text.count - range.length)
            return newMessageLength <= CustomTextAreaConfig.maxMessageSymbols
        }
    }
}

class InputTextView: UITextView {

    override open var text: String! {
        didSet {
            if !oldValue.isEmpty && text.isEmpty {
                textDidChangeProgrammatically()
            }
        }
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }

        setUpLayout()
        setUpAppearance()
    }

    open func setUpAppearance() {
        backgroundColor = .clear
        textContainer.lineFragmentPadding = 8
        font = .systemFont(ofSize: 17)
        textColor = UIColor(hex: "242729")
        textAlignment = .natural
        tintColor = UIColor(hex: "DD0A34")
    }

    open func setUpLayout() {
        isScrollEnabled = true
    }

    open func replaceSelectedText(_ text: String) {
        guard let selectedRange = selectedTextRange else {
            self.text.append(text)
            return
        }

        replace(selectedRange, withText: text)
    }

    open func textDidChangeProgrammatically() {
        delegate?.textViewDidChange?(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if frame.size.height == CustomTextAreaConfig.minHeight {
            let rect = layoutManager.usedRect(for: textContainer)
            let topInset = (frame.size.height - rect.height) / 2.0
            textContainerInset.top = max(0, topInset)
        }
    }

    override open func paste(_ sender: Any?) {
        super.paste(sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            let textCount: Int = text.count
            guard textCount >= 1 else { return }
            scrollRangeToVisible(NSRange(location: textCount - 1, length: 1))
        }
    }
}
