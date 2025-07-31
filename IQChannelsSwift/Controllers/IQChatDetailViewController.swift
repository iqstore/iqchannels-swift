import UIKit
import Combine
import SwiftUI
import PhotosUI
import SafariServices

class IQChatDetailViewController: IQViewController {
    
    // MARK: - PROPERTIES
    private let viewModel: IQChatDetailViewModel
    
    private let output: IQChannelsManagerDetailOutput
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var titleStackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [titleLabel, statusView])
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.text = viewModel.chatLabel
        
        
        let fontSize = CGFloat(IQStyle.model?.chat?.titleLabel?.textSize ?? 15)
        let isBold = IQStyle.model?.chat?.titleLabel?.textStyle?.bold ?? false
        let isItalic = IQStyle.model?.chat?.titleLabel?.textStyle?.italic ?? false
        
        var symbolicTraits: UIFontDescriptor.SymbolicTraits = []

        if isBold {
            symbolicTraits.insert(.traitBold)
        }
        if isItalic {
            symbolicTraits.insert(.traitItalic)
        }

        let systemFont = UIFont.systemFont(ofSize: fontSize)

        if let descriptor = systemFont.fontDescriptor.withSymbolicTraits(symbolicTraits) {
            label.font = UIFont(descriptor: descriptor, size: fontSize)
        } else {
            label.font = systemFont
        }
        
        
        label.textColor = IQStyle.getUIColor(theme: IQStyle.model?.chat?.titleLabel?.color) ?? UIColor(hex: "242729")
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label: UILabel = .init()
        
        let fontSize = CGFloat(IQStyle.model?.chat?.statusLabel?.textSize ?? 15)
        let isBold = IQStyle.model?.chat?.statusLabel?.textStyle?.bold ?? false
        let isItalic = IQStyle.model?.chat?.statusLabel?.textStyle?.italic ?? false
        
        var symbolicTraits: UIFontDescriptor.SymbolicTraits = []

        if isBold {
            symbolicTraits.insert(.traitBold)
        }
        if isItalic {
            symbolicTraits.insert(.traitItalic)
        }

        let systemFont = UIFont.systemFont(ofSize: fontSize)

        if let descriptor = systemFont.fontDescriptor.withSymbolicTraits(symbolicTraits) {
            label.font = UIFont(descriptor: descriptor, size: fontSize)
        } else {
            label.font = systemFont
        }
        
        label.textColor = IQStyle.getUIColor(theme: IQStyle.model?.chat?.statusLabel?.color) ?? UIColor(hex: "919399")
        return label
    }()
    
    private lazy var statusView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [loadingView, statusLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let view: UIActivityIndicatorView = .init()
        view.color = IQStyle.getUIColor(theme: IQStyle.model?.chat?.chatHistory) ?? UIColor(hex: "919399")
        view.hidesWhenStopped = true
        view.widthAnchor.constraint(equalToConstant: 24).isActive = true
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let btn: UIButton = .init(frame: .init(x: 0, y: 0, width: 24, height: 24))
        btn.setImage(UIImage(name: "chevron_left"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.addTarget(self, action: #selector(onTapBack), for: .touchUpInside)
        return btn
    }()
    
    private lazy var searchButton: UIButton = {
        let btn: UIButton = .init(frame: .init(x: 0, y: 0, width: 24, height: 24))
        btn.setImage(UIImage(name: "search"), for: [])
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        return btn
    }()
    
    private lazy var languageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.black, for: .normal)
        btn.contentHorizontalAlignment = .right
        btn.frame.size = CGSize(width: 150, height: 20)
        btn.addTarget(self, action: #selector(languageButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - INIT
    init(viewModel: IQChatDetailViewModel,
         output: IQChannelsManagerDetailOutput) {
        self.viewModel = viewModel
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - LIFECYCLE
    override func setupSwiftUI() {
        let hostView: ChatDetailView = .init(delegate: self)
        let controller: UIHostingController = .init(rootView: hostView.environmentObject(viewModel))
        setupConstructedSwiftUI(interactor: controller)
    }
    
    // MARK: - LANGUAGE
    private var dropdown: LanguageDropdownView?

    @objc private func languageButtonTapped() {
        if dropdown != nil {
            dropdown?.hide()
            dropdown = nil
            return
        }
        let menu = LanguageDropdownView()
        menu.languages = viewModel.availableLanguages ?? []
        menu.selectedCode = viewModel.selectedLanguage?.code
        menu.onSelect = { [weak self] selected in
            if let code = selected.code {
                self?.output.detailControllerSelectLanguage(didSelect: selected)
                self?.loadLanguageDataFromAppSupport(code)
            }
            
            if let label = selected.name {
                self?.languageButton.setTitle(label, for: .normal)
            }
            
            self?.dropdown = nil
            self?.viewModel.selectedLanguage = selected
            self?.statusLabel.text = IQChannelsState.authenticated.description
        }
        menu.show(from: languageButton, in: view)
        dropdown = menu
    }
    
    func loadLanguageDataFromAppSupport(_ code: String) {
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let fileURL = supportURL.appendingPathComponent("\(code).json")

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            IQLog.error(message: "Файл \(code).json не найден")
            return
        }
        let data = try? Data(contentsOf: fileURL)
        IQLog.debug(message: "Язык изменен на \(code)")
        IQLanguageTexts.configure(data)
    }
    
    override func setupNavBar() {
        if let language = UserDefaults.standard.dictionary(forKey: "selectedLanguage") as? [String: String] {
            let code = language["code"]
            let name = language["name"]
            
            if let code = code, let name = name {
                self.loadLanguageDataFromAppSupport(code)
                self.viewModel.selectedLanguage = IQLanguage(code: code, name: name, isDefault: nil, iconURL: nil)
                self.languageButton.setTitle(name, for: .normal)
            }
        }
        navigationItem.titleView = titleStackView
        navigationItem.leftBarButtonItem = .init(customView: backButton)
        navigationItem.rightBarButtonItem = .init(customView: languageButton)
    }
    
    override func bindViewModel() {
        viewModel.errorListener
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showAlert(message: error.localizedDescription)
            }.store(in: &subscriptions)
        
        viewModel.$inputText
            .dropFirst()
            .sink { [weak self] _ in
                self?.output.detailControllerIsTyping()
            }.store(in: &subscriptions)
        
        viewModel.$messageControlShown
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messageControlShown in
                self?.navigationController?.setNavigationBarHidden(true, animated: false)
            }.store(in: &subscriptions)
        
        viewModel.$hidesBackButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hidesBackButton in
                self?.backButton.isHidden = hidesBackButton
            }.store(in: &subscriptions)
        
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                UIView.transition(with: titleStackView,
                                  duration: 0.25,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    let hasNetwork = state == .authenticated
                    self.titleLabel.isHidden = !hasNetwork
                    hasNetwork ? self.loadingView.stopAnimating() : self.loadingView.startAnimating()
                    self.loadingView.isHidden = hasNetwork
                    self.loadingView.alpha = hasNetwork ? 0 : 1
                    self.statusLabel.text = state.description
                }, completion: nil)
            }.store(in: &subscriptions)
        
        viewModel.$typingUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self else { return }
                UIView.transition(with: titleStackView,
                                  duration: 0,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    if (user != nil){
                        self.statusLabel.text = "\(user?.displayName ?? "Оператор") \(IQLanguageTexts.model.operatorTyping ?? "печатает")..."
                    } else {
                        self.statusLabel.text = IQChannelsState.authenticated.description
                    }
                }, completion: nil)
            }.store(in: &subscriptions)
        
        viewModel.$chatLabel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &cancellables)
        
        viewModel.$availableLanguages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] availableLanguages in
                
                if self?.viewModel.selectedLanguage == nil {
                    self?.viewModel.selectedLanguage = availableLanguages?.filter {$0.isDefault == true}.first ?? IQLanguage(code: "ru", name: "Русский", isDefault: true, iconURL: nil)
                    
                    if let newLabel = self?.viewModel.selectedLanguage?.name {
                        self?.languageButton.setTitle(newLabel, for: .normal)
                    }
                }
                
            }
            .store(in: &cancellables)
    }
    
    // MARK: - ACTIONS
    @objc
    private func onTapBack() {
        if viewModel.backDismisses {
            output.detailControllerDismissChat()
        } else {
            output.detailControllerDidPop()
        }
    }
    
    // MARK: - PRIVATE METHODS
    private func photoSourceDidTap(source: UIImagePickerController.SourceType){
        switch source {
        case .photoLibrary, .savedPhotosAlbum:
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.selectionLimit = 10
            configuration.preferredAssetRepresentationMode = .current
            configuration.filter = PHPickerFilter.images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        case .camera:
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        @unknown default: break
        }
    }
    
    private func fileSourceDidTap(){
        let documentController = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
        documentController.delegate = self
        documentController.allowsMultipleSelection = true
        documentController.modalPresentationStyle = .formSheet
        present(documentController, animated: true)
    }
    
    private func displayAttachmentOptions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: IQLanguageTexts.model.gallery ?? "Галерея", style: .default, handler: { _ in
            self.photoSourceDidTap(source: .photoLibrary)
        }))
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(.init(title: IQLanguageTexts.model.camera ?? "Камера", style: .default, handler: { _ in
                self.photoSourceDidTap(source: .camera)
            }))
        }
        alert.addAction(.init(title: IQLanguageTexts.model.file ?? "Файл", style: .default, handler: { _ in
            self.fileSourceDidTap()
        }))
        alert.addAction(.init(title: IQLanguageTexts.model.cancel ?? "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func confirmDocumentSubmission(fileUrls: [URL]) {
        self.output.detailController(didPick: fileUrls.map { ($0, nil) })
        self.viewModel.scrollDown.toggle()
    }
    
    private func showFilePreview(file: IQFile, sessionToken: String) {
        guard let url = file.url else { return }
        if file.type == .image {
            let controller: PreviewViewController = .init(url: url)
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .coverVertical
            present(controller, animated: true)
        } else if file.type == .file {
            let controller: FilePreviewController = .init(url: url, fileName: file.name, sessionToken: sessionToken)
            present(controller, animated: true)
        }
    }
}

// MARK: - CHAT DETAIL VIEW DELEGATE
extension IQChatDetailViewController: ChatDetailViewDelegate {
    func onAttachmentTap() {
        displayAttachmentOptions()
    }
    
    func onFileTap(_ file: IQFile, sessionToken: String) {
        showFilePreview(file: file, sessionToken: sessionToken)
    }
    
    func onSingleChoiceTap(_ singleChoice: IQSingleChoice) {
        output.detailController(didSelect: singleChoice)
    }
    
    func onActionTap(_ action: IQAction) {
        output.detailController(didSelect: action)
    }
    
    func onMessageAppear(with messageId: Int) {
        output.detailController(didDisplayMessageWith: messageId)
    }
    
    func onSendMessage(_ text: String) {
        output.detailController(didSend: text, files: viewModel.selectedFiles, replyToMessage: viewModel.messageToReply?.messageID)
        viewModel.scrollDown.toggle()
    }
    
    func onResendMessage(_ message: IQMessage) {
        output.detailController(didResend: message)
    }
    
    func onCancelUpload(_ message: IQMessage) {
        output.detailController(didCancelUpload: message)
    }
    
    func onCancelSend(_ message: IQMessage) {
        output.detailController(didCancelSend: message)
    }
    
    func onRate(value: Int, ratingId: Int) {
        output.detailController(didRate: value, ratingID: ratingId)
    }
    
    func onSendPoll(value: Int?, answers: [IQRatingPollClientAnswerInput], ratingId: Int, pollId: Int) {
        output.detailController(didSendPoll: value, answers: answers, ratingID: ratingId, pollId: pollId)
    }
    
    func onPollIgnored(ratingId: Int, pollId: Int) {
        output.detailController(didPollIgnored: ratingId, pollId: pollId)
    }
}

// MARK: - PH PICKER DELEGATE
extension IQChatDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        output.detailController(didPick: results)
        viewModel.scrollDown.toggle()
    }
}

// MARK: - IMAGE PICKER DELEGATE
extension IQChatDetailViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let url = info[.imageURL] as? URL {
            output.detailController(didPick: [(url, nil)])
        } else if let image = info[.editedImage] as? UIImage {
            output.detailController(didPick: [(nil, image)])
        }
        viewModel.scrollDown.toggle()
    }
}

// MARK: - DOCUMENT PICKER DELEGATE
extension IQChatDetailViewController: UIDocumentPickerDelegate & UINavigationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        confirmDocumentSubmission(fileUrls: urls)
    }
}


final class LanguageDropdownView: UIView, UITableViewDelegate, UITableViewDataSource {

    var languages: [IQLanguage] = []
    var selectedCode: String?
    var onSelect: ((IQLanguage) -> Void)?

    private let tableView = UITableView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        overrideUserInterfaceStyle = .light
        backgroundColor = .white
        
        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10
        tableView.register(LanguageCell.self, forCellReuseIdentifier: "LanguageCell")

        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func show(from anchor: UIView, in parent: UIView) {
        guard anchor.superview != nil else { return }
        parent.addSubview(self)

        let anchorFrame = anchor.convert(anchor.bounds, to: parent)
        frame = CGRect(x: anchorFrame.minX,
                       y: anchorFrame.maxY + 8,
                       width: 150,
                       height: CGFloat(min(languages.count, 5)) * 44)
    }

    func hide() {
        removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath) as? LanguageCell else {
            return UITableViewCell()
        }

        let lang = languages[indexPath.row]
        let isSelected = lang.code == selectedCode
        cell.configure(with: lang, selected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lang = languages[indexPath.row]
        selectedCode = lang.code
        tableView.reloadData()
        onSelect?(lang)
        hide()
    }
}

final class LanguageCell: UITableViewCell {
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        nameLabel.font = .systemFont(ofSize: 16)

        let stack = UIStackView(arrangedSubviews: [nameLabel])
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            stack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12),
            stack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12)
        ])
    }

    func configure(with language: IQLanguage, selected: Bool) {
        nameLabel.text = language.name
        
        if (selected){
            nameLabel.font = .boldSystemFont(ofSize: nameLabel.font.pointSize)
        }
    }
}
