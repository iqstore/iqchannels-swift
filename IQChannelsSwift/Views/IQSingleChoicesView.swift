import UIKit

protocol IQSingleChoicesViewDelegate: AnyObject {
    func singleChoicesView(_ view: IQSingleChoicesView, didSelectOption singleChoice: IQSingleChoice)
}

class IQSingleChoicesView: UIView {
    
    weak var delegate: IQSingleChoicesViewDelegate?
    
    private lazy var stackView: UIStackView = .init()
    private var buttonsArray: [UIButton] = []
    private var singleChoices: [IQSingleChoice] = []
    
    init() {
        super.init(frame: .zero)
        setupViews()
        setLayoutConstraints()
        setStyleProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(stackView)
    }

    private func setLayoutConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setStyleProperties() {
        backgroundColor = .clear
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.alignment = .trailing
        stackView.spacing = 4
    }

    func setSingleChoices(_ singleChoices: [IQSingleChoice]) {
        self.singleChoices = singleChoices
        let screenWidth = UIScreen.main.bounds.size.width
        var index = 0
        var choiceIndex = 0
        repeat {
            let lineView = UIStackView()
            lineView.spacing = 4
            var lineWidth: CGFloat = 0
            while choiceIndex < singleChoices.count {
                let title = singleChoices[choiceIndex].title ?? ""
                let boundingRect = (title as NSString).boundingRect(with: CGSize(width: -1, height: -1), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 12)], context: nil)
                let choiceWidth = 6 + boundingRect.size.width + 6 + 1
                lineWidth += choiceWidth
                if lineWidth > screenWidth {
                    break
                }
                choiceIndex += 1
                let button = getNewButton(withTitle: title, width: choiceWidth - 4, height: 32)
                lineView.addArrangedSubview(button)
                buttonsArray.append(button)
            }
            index += 1
            stackView.addArrangedSubview(lineView)
        } while choiceIndex < singleChoices.count
    }

    func clearSingleChoices() {
        singleChoices.removeAll()
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        buttonsArray.removeAll()
    }

    private func getNewButton(withTitle title: String, width: CGFloat, height: CGFloat) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        let color = UIColor(red: 136 / 255.0, green: 186 / 255.0, blue: 73 / 255.0, alpha: 1)
        button.setTitleColor(color, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        return button
    }

    @objc private func buttonAction(_ button: UIButton) {
        if let index = buttonsArray.firstIndex(of: button) {
            delegate?.singleChoicesView(self, didSelectOption: singleChoices[index])
        }
    }
}
