import UIKit
import SwiftUI
import PhotosUI
import SafariServices

class IQChatDetailViewController: IQViewController {
    
    // MARK: - PROPERTIES
    private let viewModel: IQChatDetailViewModel
    
    private let output: IQChannelsManagerDetailOutput
    
    private lazy var titleStackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [titleLabel, statusView])
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.text = "Сообщения"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor(hex: "242729")
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
        view.color = Style.getUIColor(theme: Style.model?.chat?.chatHistory) ?? UIColor(hex: "919399")
        view.hidesWhenStopped = true
        view.widthAnchor.constraint(equalToConstant: 24).isActive = true
        return view
    }()
    
    private lazy var statusLabel: UILabel = {
        let label: UILabel = .init()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = Style.getUIColor(theme: Style.model?.chat?.chatHistory) ?? UIColor(hex: "919399")
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let btn: UIButton = .init(frame: .init(x: 0, y: 0, width: 32, height: 32))
        btn.setImage(UIImage(name: "chevron_left"), for: [])
        btn.imageView?.contentMode = .scaleAspectFill
        btn.addTarget(self, action: #selector(onTapBack), for: .touchUpInside)
        return btn
    }()
    
    private lazy var searchButton: UIButton = {
        let btn: UIButton = .init(frame: .init(x: 0, y: 0, width: 32, height: 32))
        btn.setImage(UIImage(name: "search"), for: [])
        btn.imageView?.contentMode = .scaleAspectFill
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
    
    override func setupNavBar() {
        navigationItem.titleView = titleStackView
        navigationItem.leftBarButtonItem = .init(customView: backButton)
    }
    
    override func bindViewModel() {
        viewModel.errorListener
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showAlert(message: error.localizedDescription)
            }.store(in: &subscriptions)
        
        viewModel.$inputText
            .sink { [weak self] _ in
                self?.output.detailControllerIsTyping()
            }.store(in: &subscriptions)
        
        viewModel.$messageControlShown
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messageControlShown in
                self?.navigationController?.setNavigationBarHidden(messageControlShown, animated: false)
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
    }
    
    // MARK: - ACTIONS
    @objc
    private func onTapBack() {
        output.detailControllerDidPop()
        navigationController?.popViewController(animated: true)
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
        alert.addAction(.init(title: "Галерея", style: .default, handler: { _ in
            self.photoSourceDidTap(source: .photoLibrary)
        }))
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(.init(title: "Камера", style: .default, handler: { _ in
                self.photoSourceDidTap(source: .camera)
            }))
        }
        alert.addAction(.init(title: "Файл", style: .default, handler: { _ in
            self.fileSourceDidTap()
        }))
        alert.addAction(.init(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func confirmDocumentSubmission(fileUrls: [URL]) {
        let title = fileUrls.count > 10 ? "За один раз можно отправить не более 10 файлов. Вы действительно желаете отправить первые выбранные 10 файлов?" : "Подтвердите отправку файлов(\(fileUrls.count))"
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(.init(title: "Отправить", style: .default, handler: { _ in
            self.output.detailController(didPick: fileUrls.map { ($0, nil) }, replyToMessage: self.viewModel.messageToReply?.messageID)
            self.viewModel.inputText = ""
            self.viewModel.messageToReply = nil
            self.viewModel.scrollDown.toggle()
        }))
        alertController.addAction(.init(title: "Отмена", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func showFilePreview(file: IQFile) {
        guard let url = file.url else { return }
        if file.type == .image {
            let controller: PreviewViewController = .init(url: url)
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .coverVertical
            present(controller, animated: true)
        } else if file.type == .file {
            let controller: FilePreviewController = .init(url: url)
            present(controller, animated: true)
        }
    }
}

// MARK: - CHAT DETAIL VIEW DELEGATE
extension IQChatDetailViewController: ChatDetailViewDelegate {
    func onAttachmentTap() {
        displayAttachmentOptions()
    }
    
    func onFileTap(_ file: IQFile) {
        showFilePreview(file: file)
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
        output.detailController(didSend: text, replyToMessage: viewModel.messageToReply?.messageID)
        viewModel.scrollDown.toggle()
    }
    
    func onCancelUpload(_ message: IQMessage) {
        output.detailController(didCancelUpload: message)
    }
    
    func onRate(value: Int, ratingId: Int) {
        output.detailController(didRate: value, ratingID: ratingId)
    }
}

// MARK: - PH PICKER DELEGATE
extension IQChatDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        output.detailController(didPick: results, replyToMessage: viewModel.messageToReply?.messageID)
        viewModel.inputText = ""
        viewModel.messageToReply = nil
        viewModel.scrollDown.toggle()
    }
}

// MARK: - IMAGE PICKER DELEGATE
extension IQChatDetailViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let url = info[.imageURL] as? URL {
            output.detailController(didPick: [(url, nil)], replyToMessage: viewModel.messageToReply?.messageID)
        } else if let image = info[.editedImage] as? UIImage {
            output.detailController(didPick: [(nil, image)], replyToMessage: viewModel.messageToReply?.messageID)
        }
        viewModel.inputText = ""
        viewModel.messageToReply = nil
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
