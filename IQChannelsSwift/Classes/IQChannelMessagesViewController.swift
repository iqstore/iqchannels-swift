import UIKit
import MessageKit
import SDWebImage
import InputBarAccessoryView
import PhotosUI

open class IQChannelMessagesViewController: MessagesViewController, UIGestureRecognizerDelegate {
    
    //MARK: - VIEWS
    private var messagesIndicator = IQActivityIndicator()
    private var loginIndicator = IQActivityIndicator()
    private var scrollDownButton = IQScrollDownButton()
    private var chatUnavailableView = IQChatUnavailableView()
    private var pendingReplyView = IQPendingReplyView()
    private var refreshControl = UIRefreshControl()
    
    // MARK: - PROPERTIES
    private var client: IQClient?
    private var messages: [IQChatMessage] = []
    private var stateSub: IQSubscription?
    private var state: IQChannelsState = .loggedOut
    private var visible: Bool = false
    private var readMessages: Set<Int> = []
    private var typingTimer: Timer?
    private var typingUser: IQUser?
    /// Set only via reply(to:) method
    private var _messageToReply: IQChatMessage?
    private var messagesSub: IQSubscription?
    private var moreMessagesLoading: IQSubscription?    
    private var slideCellManager = IQSlideCellManager()
    private var messagesLoaded: Bool = false
        
    // MARK: - LIFECYCLE
    public override func viewDidLoad() {
        messagesCollectionView = MessagesCollectionView(frame: .zero,
                                                        collectionViewLayout: CustomMessagesFlowLayout())
        
        super.viewDidLoad()
        
        setupIndicators()
        setupRefreshControl()
        setupNavBar()
        setupChatUnavailableView()
        setupScrollDownButton()
        setupPendingReplyView()
        setupCollectionView()
        setupInputBar()
        setupObservers()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stateSub = IQChannels.state(self)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visible = true

        if readMessages.count > 0 {
            for messageId in readMessages {
                IQChannels.markAsRead(messageId)
            }
            readMessages.removeAll()
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visible = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - PUBLIC METHODS
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    func scrollToBottomIfNeeded(animated: Bool = true){
        if shouldHideScrollDownButton(){
            messagesCollectionView.scrollToBottom(animated: animated)
            scrollDownButton.dotHidden = true
        }
    }
    
    func shouldHideScrollDownButton() -> Bool {
        let offset = messagesCollectionView.contentOffset.y + messagesCollectionView.frame.height
        return !(offset < messagesCollectionView.contentSize.height - 200)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let shouldHide = shouldHideScrollDownButton()
        let targetAlpha: CGFloat = shouldHide ? 0 : 1
        if shouldHide {
            scrollDownButton.dotHidden = true
        }
        guard scrollDownButton.alpha != targetAlpha else { return }
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.scrollDownButton.alpha = targetAlpha
        }
    }
    
    // MARK: - CELL FOR ITEM
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isSectionReservedForTypingIndicator(indexPath.section){
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        let message = messages[indexPath.row]
        
        if message.isMediaMessage {
            IQChannels.loadMessageMedia(message.id)
        }
        
        if !message.isMy,
           (messages.count - 1 == indexPath.item) {
            setInputToolbarEnabled(!message.disableFreeText)
        }
        
        if !message.isMy {
            if (visible) {
                IQChannels.markAsRead(message.id)
            } else {
                readMessages.update(with: message.id)
            }
        }
        
        if case .custom = message.kind {
            if message.payload == .singleChoice {
                let cell = messagesCollectionView.dequeueReusableCell(IQStackedSingleChoicesCell.self, for: indexPath)
                cell.setSingleChoices(message.singleChoices ?? [])
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                cell.stackedSingleChoicesDelegate = self
                cell.delegate = self
                return cell
            } else if message.payload == .card || message.payload == .carousel {
                let cell = messagesCollectionView.dequeueReusableCell(IQCardCell.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                cell.cardCellDelegate = self
                cell.delegate = self
                slideCellManager.add(cell)
                return cell
            }
            
            if message.file?.type == .file {
                let cell = messagesCollectionView.dequeueReusableCell(IQFilePreviewCell.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                cell.delegate = self
                cell.replyViewDelegate = self
                slideCellManager.add(cell)
                return cell
            }
            
            let cell = messagesCollectionView.dequeueReusableCell(MyCustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        } else if case .text = message.kind {
            if message.isPendingRatingMessage{
                let cell = messagesCollectionView.dequeueReusableCell(IQRatingCell.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                cell.delegate = self
                cell.ratingDelegate = self
                slideCellManager.add(cell)
                return cell
            }
            if message.payload == .singleChoice,
               message.isDropDown,
               messages.count - 1 == indexPath.row,
               !(message.singleChoices?.isEmpty ?? true){
                let cell = messagesCollectionView.dequeueReusableCell(IQSingleChoicesCell.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                cell.singleChoiceDelegate = self
                cell.delegate = self
                return cell
            }
        }
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        if let cell = cell as? MessageContentCell {
            cell.delegate = self
            slideCellManager.add(cell)
        }
        return cell
    }
}

// MARK: - MESSAGES COLLECTION VIEW
extension IQChannelMessagesViewController {
    
    open func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let collectionView = collectionView as? MessagesCollectionView,
              let messagesDataSource = collectionView.messagesDataSource,
              let indexPath = indexPaths.first else {
            return nil
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: collectionView)
        var textToCopy: String = ""
        switch message.kind {
        case .text(let text), .emoji(let text):
            textToCopy = text
        case .attributedText(let attributedText):
            textToCopy = attributedText.string
        default:
            return nil
        }
        
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            let copy = UIAction(title: "Копировать", image: UIImage(systemName: "doc.on.doc"), identifier: nil, discoverabilityTitle: nil, state: .off) { [weak self] (_) in
                UIPasteboard.general.string = textToCopy
                self?.showCopyPreviewView()
            }
            let reply = UIAction(title: "Ответить", image: UIImage(systemName: "arrowshape.turn.up.left"), identifier: nil, discoverabilityTitle: nil, state: .off) { [weak self] (_) in
                if let message = message as? IQChatMessage {
                    self?.reply(to: message)
                }
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [copy, reply])
        }
        return context
    }
    
    open func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        return contextMenuPreview(collectionView: collectionView, indexPath: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        return contextMenuPreview(collectionView: collectionView, indexPath: indexPath)
    }
}

//MARK: - INPUT BAR DELEGATE
extension IQChannelMessagesViewController: InputBarAccessoryViewDelegate {
    
    @objc func inputBarDidBeginEditing(){
        DispatchQueue.main.async {
            self.scrollToBottomIfNeeded()
        }
    }
    
    @objc func keyboardFrameDidChange(_ notification: Notification){
        guard let rect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let height = self.view.frame.height - rect.origin.y
        UIView.animate(withDuration: 0.2) {
            self.pendingReplyView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(height).priority(.high)
            }
            self.scrollDownButton.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(height + 16).priority(.high)
            }
            self.view.layoutIfNeeded()
        }
    }
        
    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if !messagesLoaded {
            return
        }
        inputBar.inputTextView.text = nil
        IQChannels.sendText(text, replyMessageID: _messageToReply?.id)
        reply(to: nil)
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    public func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        IQChannels.typing()
        if text.isEmpty {
            if messageInputBar.rightStackViewWidthConstant != .zero {
                messageInputBar.setRightStackViewWidthConstant(to: .zero, animated: true)
            }
        } else {
            if messageInputBar.rightStackViewWidthConstant != 40 {
                messageInputBar.setRightStackViewWidthConstant(to: 40, animated: true)
            }
        }
    }
    
    func setInputToolbarEnabled(_ enabled: Bool) {
        self.messageInputBar.inputTextView.isEditable = enabled
        self.messageInputBar.leftStackView.isUserInteractionEnabled = enabled
    }
}

// MARK: - MESSAGES DATA SOURCE
extension IQChannelMessagesViewController: MessagesDataSource, MessageCellDelegate {
    public func currentSender() -> MessageKit.SenderType {
        return MessageSender(senderId: client?.senderId ?? "",
                             displayName: client?.senderDisplayName ?? "")
    }
    
    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.row]
    }
    
    public func typingIndicator(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
        let indicator = messagesCollectionView.dequeueReusableCell(IQTypingIndicatorCell.self, for: indexPath)
        indicator.textLabel.text = "\(typingUser?.displayName ?? "") печатает..."
        return indicator
    }
    
    public func photoCell(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        let cell = messagesCollectionView.dequeueReusableCell(IQMediaMessageCell.self, for: indexPath)
        cell.configure(with: message, at: indexPath, and: messagesCollectionView)
        cell.replyViewDelegate = self
        cell.delegate = self
        return cell
    }
    
    public func textCell(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        let cell = messagesCollectionView.dequeueReusableCell(
          IQTimestampMessageCell.self,
          for: indexPath)
        cell.configure(with: message, at: indexPath, and: messagesCollectionView)
        cell.delegate = self
        cell.replyViewDelegate = self
        return cell
    }
    
    public func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return 1
    }
    
    public func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    public func didTapMessage(in cell: MessageCollectionViewCell) {
        handleTap(at: cell)
    }
    
    public func didTapImage(in cell: MessageCollectionViewCell) {
        handleTap(at: cell)
    }
    
    public func didSelectURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
    
    private func handleTap(at cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              messages.indices.contains(indexPath.row) else { return }
        
        let message = messages[indexPath.row]
        if let file = message.file {
            let filename = file.type?.rawValue == "image" ? "фото" : file.name
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Открыть \(filename ?? "файл") в браузере", style: .default, handler: { _ in
                self.openMessageInBrowser(messageID: message.id)
            }))
            alert.addAction(.init(title: "Отмена", style: .cancel))
            messageInputBar.inputTextView.resignFirstResponder()
            present(alert, animated: true)
        }
    }
}

//MARK: - IQSLIDECELLMANAGERDELEGATE
extension IQChannelMessagesViewController: IQSlideCellManagerDelegate {
 
    func slideManager(_ manager: IQSlideCellManager, slideDidOccurAt cell: MessageContentCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              messages.indices.contains(indexPath.row) else { return }
        
        let message = messages[indexPath.row]
        
        reply(to: message)
    }
   
}

// MARK: - MESSAGES LAYOUT DELEGATE
extension IQChannelMessagesViewController: MessagesLayoutDelegate {
    public func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        .bubble
    }
    
    public func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard isGroupStart(indexPath) else {
            return 0
        }
        
        let message = messages[indexPath.row]
        guard message.user != nil else {
            return 0
        }
        
        return 20
    }
    
    public func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if !shouldDisplayMessageDate(indexPath) {
            return 0
        }
        
        return 56
    }
    
}

// MARK: - MESSAGES DISPLAY DELEGATE
extension IQChannelMessagesViewController: MessagesDisplayDelegate {
    
    public func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard isGroupStart(indexPath) else {
            return nil
        }
        
        guard let message = message as? IQChatMessage,
              let user = message.user,
              let displayName = user.displayName else {
            return nil
        }
        
        return NSAttributedString(string: displayName, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11),
                                                                    NSAttributedStringKey.foregroundColor : UIColor.lightGray])
    }
    
    public func detectorAttributes(for detector: DetectorType, and message: any MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        [
            .foregroundColor: UIColor.link
        ]
    }
    
    public func enabledDetectors(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    public func backgroundColor(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        guard let dataSource = messagesCollectionView.messagesDataSource else { return .jsq_messageBubbleLightGray() }
        let isSender = dataSource.isFromCurrentSender(message: message)
        return isSender ? .init(hex: 0x242729) : .init(hex: 0xF4F4F8)
    }
    
    public func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard shouldDisplayMessageDate(indexPath) else {
            return nil
        }
        
        let index = indexPath.row
        let message = messages[index]
        
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.locale = .init(identifier: "ru_RU")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: message.sentDate)
        return NSAttributedString(string: date, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13),
                                                             NSAttributedStringKey.foregroundColor : UIColor.init(hex: 0x919399)])
    }
    
    public func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let message = messages[indexPath.row]
        avatarView.isHidden = false

        guard !message.isMy,
              isGroupStart(indexPath),
              let user = message.user else {
            avatarView.isHidden = true
            return
        }
        let initials = String((message.user?.name ?? "").prefix(1))

        if let avatarImage = user.avatarImage {
            let avatar: Avatar = .init(image: avatarImage)
            avatarView.set(avatar: avatar)
        } else if let url = user.avatarURL {
            avatarView.set(avatar: .init(initials: initials))
            SDWebImageManager.shared.loadImage(with: url, progress: nil) { [weak self] image, _, _, _, _, _ in
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    let index: Int
                    if message.isMy {
                        index = self.getMyMessageByLocalId(localId: message.localId)
                    } else {
                        index = self.getMessageIndexById(messageId: message.id)
                    }
                    self.messages[index].user?.avatarImage = image
                    if let cell = (messagesCollectionView.cellForItem(at: .init(item: index, section: 0)) as? MessageContentCell) {
                        cell.avatarView.set(avatar: .init(image: image))
                    }
                }
            }
        } else {
            let avatar: Avatar = .init(initials: initials)
            avatarView.set(avatar: avatar)
        }
        avatarView.backgroundColor = UIColor.paletteColorFromString(string: user.name)
    }

}

//MARK: - DATA PICKER DELEGATE
extension IQChannelMessagesViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate, UIDocumentPickerDelegate, PHPickerViewControllerDelegate{
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProviders = results.map(\.itemProvider)
        for (index, item) in itemProviders.enumerated() {
            if item.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                item.loadDataRepresentation(forTypeIdentifier: UTType.gif.identifier) { data, _ in
                    guard let data else { return }
                    DispatchQueue.main.async {
                        self.sendData(data: data, filename: "gif", replyMessageID: self._messageToReply?.id)
                    }
                }
            } else {
                item.loadImage { image, error in
                    if let image {
                        DispatchQueue.main.async {
                            self.sendImage(image, filename: nil, replyMessageID: self._messageToReply?.id)
                        }
                    }
                }
            }
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        if let url = info[UIImagePickerControllerImageURL] as? URL,
           url.pathExtension == "gif",
           let data = try? Data(contentsOf: url){
            sendData(data: data, filename: "gif", replyMessageID: _messageToReply?.id)
            return
        }
        
        sendImage(image, filename: nil, replyMessageID: _messageToReply?.id)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        let files: [(data: Data, filename: String)] = urls.compactMap { url in
            defer { url.stopAccessingSecurityScopedResource() }
            
            guard url.startAccessingSecurityScopedResource(),
                  let data = try? Data(contentsOf: url) else { return nil }
            
            return (data, url.lastPathComponent)
        }
        
        DispatchQueue.main.async {
            self.confirmDataSubmission(files)
        }
    }
    
    public func confirmDataSubmission(_ files: [(data: Data, filename: String)]) {
        let title = files.count > 10 ? "За один раз можно отправить не более 10 файлов. Вы действительно желаете отправить первые выбранные 10 файлов?" : "Подтвердите отправку файлов(\(files.count))"
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(.init(title: "Отправить", style: .default, handler: { _ in
            files.prefix(10).enumerated().forEach { index, turtle in
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * 0.5)) {
                    self.sendData(data: turtle.data, filename: turtle.filename, replyMessageID: self._messageToReply?.id)
                }
            }
        }))
        alertController.addAction(.init(title: "Отмена", style: .cancel))
        messageInputBar.inputTextView.resignFirstResponder()
        present(alertController, animated: true)
    }
    
    public func showLimitReachedAlert() {
        let alertController = UIAlertController(title: "Выберите до 10 файлов, для успешной отправки", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(.init(title: "Подтвердить", style: .cancel))
        messageInputBar.inputTextView.resignFirstResponder()
        present(alertController, animated: true)
    }
    
    public func sendData(data: Data, filename: String?, replyMessageID: Int?) {
        reply(to: nil)
        IQChannels.sendData(data, filename: filename, replyMessageID: replyMessageID)
    }
    
    public func sendImage(_ image: UIImage, filename: String?, replyMessageID: Int?) {
        reply(to: nil)
        IQChannels.sendImage(image, filename: filename, replyMessageID: replyMessageID)
    }
}

// MARK: - STATE LISTENER
extension IQChannelMessagesViewController: IQChannelsStateListenerProtocol {
    var id: String { UUID().uuidString }
    
    private func clearState() {
        stateSub?.unsubscribe()

        client = nil
        state = .loggedOut
        stateSub = nil
    }

    func iqLoggedOut(_ state: IQChannelsState) {
        self.state = state
        loginIndicator.stopAnimating()
        setChatUnavailable(hidden: false)
    }

    func iqAwaitingNetwork(_ state: IQChannelsState) {
        self.state = state
        
        loginIndicator.label.text = "Ожидание сети..."
        setChatUnavailable(hidden: true)
        loginIndicator.startAnimating()
    }

    func iqAuthenticating(_ state: IQChannelsState) {
        self.state = state
        
        loginIndicator.label.text = "Авторизация..."
        setChatUnavailable(hidden: true)
        loginIndicator.startAnimating()
    }

    func iqAuthenticated(_ state: IQChannelsState, client: IQClient) {
        self.state = state
        self.client = client
        
        loadMessages()
        loginIndicator.label.text = ""
        setChatUnavailable(hidden: true)
        loginIndicator.stopAnimating()
    }
}

//MARK: - ChoiceDelegates
extension IQChannelMessagesViewController: IQCardCellDelegate, IQStackedSingleChoicesCellDelegate, IQSingleChoicesViewDelegate, IQRatingCellDelegate, IQCellReplyViewDelegate {
    
    func cell(_ cell: MessageContentCell, didTapReplyView: IQCellReplyView) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              messages.indices.contains(indexPath.row),
              let replyId = messages[indexPath.row].replyToMessageID,
              let row = messages.firstIndex(where: { $0.id == replyId }) else { return }
        
        messagesCollectionView.scrollToItem(at: .init(row: row, section: 0), at: .centeredVertically, animated: true)
    }
    
    func cell(didTapSendButtonFrom cell: IQRatingCell, value: Int) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
        let ratingId = messages[indexPath.row].ratingId else { return }
        
        IQChannels.rate(ratingId, value: value)
    }
    
    func singleChoicesView(_ view: IQSingleChoicesView, didSelectOption singleChoice: IQSingleChoice) {
        IQChannels.sendSingleChoice(singleChoice)
    }

    func stackedSingleChoicesCell(_ cell: IQStackedSingleChoicesCell, didSelectOption singleChoice: IQSingleChoice) {
        IQChannels.sendSingleChoice(singleChoice)
    }
    
    func cardCell(_ cell: IQCardCell, didSelectOption option: IQAction) {
        switch option.action {
        case "Postback", "Say something":
            IQChannels.sendAction(option)
        case "Open URL":
            guard let url = URL(string: option.url ?? "") else { return }
            
            UIApplication.shared.open(url)
        default: break
        }
    }
    
}

// MARK: - MESSAGES LISTENER
extension IQChannelMessagesViewController: IQChannelsMessagesListenerProtocol, IQChannelsMoreMessagesListenerProtocol {
    private func clearMessages() {
        messagesIndicator.stopAnimating()
        messagesSub?.unsubscribe()

        messages = []
        readMessages = []
        messagesSub = nil
        messagesLoaded = false
    }
    
    private func loadMoreMessages() {
        guard client != nil, messagesLoaded else { return }

        moreMessagesLoading = IQChannels.moreMessages(self)
        refreshControl.beginRefreshing()
    }
    
    func reply(to message: IQChatMessage?) {
        _messageToReply = message
        if let message {
            pendingReplyView.configure(message)
        }
        pendingReplyView.isHidden = message == nil
        additionalBottomInset = message == nil ? 0 : (56 + 16)
        if message != nil {
            messageInputBar.inputTextView.becomeFirstResponder()
            scrollToBottomIfNeeded()
        }
    }
    
    func iqMoreMessagesLoaded() {
        guard moreMessagesLoading != nil else { return }

        moreMessagesLoading = nil
        refreshControl.endRefreshing()
    }
    
    func iqMoreMessagesError(_ error: Error) {
        guard moreMessagesLoading != nil else { return }

        moreMessagesLoading = nil;
        refreshControl.endRefreshing()
        present(UIAlertController(error: error), animated: true)
    }

    private func loadMessages() {
        guard client != nil, messagesSub == nil, !messagesLoaded else { return }

        messagesSub = IQChannels.messages(self)
        messagesIndicator.label.text = "Загрузка..."
        messagesIndicator.startAnimating()
    }

    func iq(messagesError error: Error) {
        guard messagesSub != nil else { return }

        messagesSub = nil
        messagesIndicator.stopAnimating()
        refreshControl.endRefreshing()
        present(UIAlertController(error: error), animated: true)
    }

    func iq(messages: [IQChatMessage], moreMessages: Bool) {
        guard messagesSub != nil else { return }
        
        self.messages = messages
        linkReplyMessages()
        readMessages = []
        messagesLoaded = true
        
        messagesIndicator.stopAnimating()
        refreshControl.endRefreshing()
        messagesCollectionView.reloadData()
        if !moreMessages {
            messagesCollectionView.scrollToBottom()
        }
    }

    func iqMessagesCleared() {
        clearMessages()

        refreshControl.endRefreshing()
        
        messagesCollectionView.reloadData()
        messagesIndicator.stopAnimating()
        messagesCollectionView.scrollToBottom()
    }

    func iq(messageAdded message: IQChatMessage) {
        messages.append(message)
        linkReplyMessages()
        scrollDownButton.dotHidden = false
        messagesCollectionView.reloadData()
        scrollToBottomIfNeeded(animated: false)
    }

    func iq(messageSent message: IQChatMessage) {
        messages.append(message)
        linkReplyMessages()
        messagesCollectionView.reloadData()
        scrollToBottomIfNeeded()
    }

    func iq(messageUpdated message: IQChatMessage) {
        guard let index = getMessageIndex(message) else {
            return
        }

        messages[index] = message
        linkReplyMessages()
        var paths = [IndexPath]()
        paths.append(IndexPath(item: index, section: 0))
        if index > 0 {
            paths.append(IndexPath(item: index - 1, section: 0))
        }
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadItems(at: paths)      
        }
    }
    
    func iq(messagesRemoved messages: [IQChatMessage]) {
        guard messagesSub != nil else { return }
        
        let remoteMessages = messages
        
        var index = 0
        var paths = [IndexPath]()
        for localMessage in self.messages {
            for remoteMessage in remoteMessages {
                if localMessage.id == remoteMessage.id {
                    paths.append(IndexPath(item: index, section: 0))
                }
            }
            
            index += 1
        }
        
        self.messages.remove(elementsAtIndices: paths.map { $0.item })
        messagesCollectionView.deleteItems(at: paths)
    }
    
    func iq(messageTyping user: IQUser?) {
        if isTypingIndicatorHidden {
            setupTypingTimer()
        } else {
            extendByTime(2)
        }
        
        typingUser = user
        setTypingIndicatorViewHidden(false, animated: false)
        
        DispatchQueue.main.async {
            self.scrollToBottomIfNeeded()
        }
    }
    
    private func linkReplyMessages(){
        messages.filter { $0.replyToMessageID != nil }.forEach { message in
            guard let replyID = message.replyToMessageID else { return }
            
            message.replyToMessage = messages.first(where: { $0.id == replyID })
        }
    }
}

open class MyCustomCell: UICollectionViewCell {
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        self.contentView.backgroundColor = UIColor.clear
    }
}

extension Array {
    mutating func remove(elementsAtIndices indicesToRemove: [Int]) -> [Element] {
        var shouldRemove: [Bool] = .init(repeating: false, count: count)
        
        for ix in indicesToRemove {
            shouldRemove[ix] = true
        }
        
        // Copy the removed elements in the specified order.
        let removedElements = indicesToRemove.map { self[$0] }
        
        // Compact the array
        var j = 0
        for i in 0..<count {
            if !shouldRemove[i] {
                self[j] = self[i]
                j+=1
            }
        }
        
        // Remove the extra elements from the end of the array.
        self.removeLast(count-j)
        
        return removedElements
    }
}

// MARK: - PRIVATE EXTENSION
private extension IQChannelMessagesViewController {
    
    // MARK: - METHODS
    func setupCollectionView() {
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.init(width: 40, height: 40))
        layout?.setMessageIncomingMessageTopLabelAlignment(.init(textAlignment: .left, textInsets: .init(top: 0, left: 68, bottom: 0, right: 0)))
        layout?.setMessageIncomingMessagePadding(.init(top: 0, left: 8, bottom: 0, right: 40))
        layout?.setMessageIncomingAvatarPosition(AvatarPosition(vertical: .messageBottom))
        layout?.setMessageIncomingCellBottomLabelAlignment(.init(textAlignment: .left,
                                                                 textInsets: .zero))
        layout?.setMessageOutgoingCellBottomLabelAlignment(.init(textAlignment: .right,
                                                                 textInsets: .zero))
        messagesCollectionView.register(IQCardCell.self, forCellWithReuseIdentifier: IQCardCell.cellIdentifier)
        messagesCollectionView.register(IQSingleChoicesCell.self, forCellWithReuseIdentifier: IQSingleChoicesCell.cellIdentifier)
        messagesCollectionView.register(IQStackedSingleChoicesCell.self, forCellWithReuseIdentifier: IQStackedSingleChoicesCell.cellIdentifier)
        messagesCollectionView.register(MyCustomCell.self, forCellWithReuseIdentifier: MyCustomCell.cellIdentifier)
        messagesCollectionView.register(IQFilePreviewCell.self, forCellWithReuseIdentifier: IQFilePreviewCell.cellIdentifier)
        messagesCollectionView.register(IQTimestampMessageCell.self, forCellWithReuseIdentifier: IQTimestampMessageCell.cellIdentifier)
        messagesCollectionView.register(IQMediaMessageCell.self, forCellWithReuseIdentifier: IQMediaMessageCell.cellIdentifier)
        messagesCollectionView.register(IQRatingCell.self, forCellWithReuseIdentifier: IQRatingCell.cellIdentifier)
        messagesCollectionView.register(IQMediaMessageCell.self, forCellWithReuseIdentifier: IQMediaMessageCell.cellIdentifier)
        messagesCollectionView.register(IQTypingIndicatorCell.self, forCellWithReuseIdentifier: IQTypingIndicatorCell.cellIdentifier)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        let gr = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        gr.delegate = self
        messagesCollectionView.addGestureRecognizer(gr)
        
        slideCellManager.delegate = self
    }
    
    func setupInputBar(){
        messageInputBar.delegate = self
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.backgroundColor = .init(hex: 0xF4F4F8)
        messageInputBar.inputTextView.placeholder = "Сообщение"
        messageInputBar.inputTextView.textContainerInset = .init(top: 9, left: 16, bottom: 9, right: 16)
        messageInputBar.inputTextView.placeholderLabelInsets.left += 4
        messageInputBar.inputTextView.tintColor = .init(hex: 0xDD0A34)
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.padding = .init(top: 8, left: 12, bottom: 8, right: 12)
        messageInputBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        messageInputBar.sendButton.configure {
            $0.layer.cornerRadius = 20
            $0.backgroundColor = .init(hex: 0x242729)
            $0.setImage(.init(systemName: "arrow.up"), for: .normal)
            $0.imageView?.tintColor = .white
            $0.setTitle(nil, for: .normal)
            $0.setSize(.init(width: 40, height: 40), animated: false)
        }
        messageInputBar.middleContentViewPadding.left = 8
        let button = IQAttachmentButton()
        button.addTarget(self, action: #selector(attachmentDidTap), for: .touchUpInside)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: .zero, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: false)
    }
    
    func setupPendingReplyView(){
        view.addSubview(pendingReplyView)
        pendingReplyView.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(0).priority(.high)
        }
        pendingReplyView.onCloseDidTap = { [unowned self] in
            reply(to: nil)
        }
        reply(to: nil)
    }
    
    func setupScrollDownButton(){
        view.addSubview(scrollDownButton)
        scrollDownButton.alpha = 0
        scrollDownButton.addTarget(self, action: #selector(scrollDownDidTap), for: .touchUpInside)
        scrollDownButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(0).priority(.high)
        }
    }
    
    func setupRefreshControl(){
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        messagesCollectionView.refreshControl = refreshControl
    }
    
    func setupTypingTimer() {
        typingTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(onTick), userInfo: nil, repeats: false)
        if typingTimer == nil {
            typingTimer?.invalidate()
        }
    }
    
    func setupChatUnavailableView(){
        view.addSubview(chatUnavailableView)
        setChatUnavailable(hidden: true)
        chatUnavailableView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        chatUnavailableView.onBackTapped = { [weak self] in
            guard let self else { return }
            
            if navigationController?.viewControllers.first === self {
                dismiss(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setChatUnavailable(hidden: Bool) {
        chatUnavailableView.isHidden = hidden
        messagesCollectionView.isHidden = !hidden
        messageInputBar.isHidden = !hidden
    }
    
    func setupIndicators(){
        view.addSubview(loginIndicator)
        view.addSubview(messagesIndicator)
        loginIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        messagesIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func setupNavBar() {
        navigationItem.title = "Сообщения"
    }
    
    func setupObservers(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(IQChannelMessagesViewController.inputBarDidBeginEditing),
                                               name: NSNotification.Name.UITextViewTextDidBeginEditing, object: messageInputBar.inputTextView)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(IQChannelMessagesViewController.keyboardFrameDidChange),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func photoSourceDidTap(source: UIImagePickerController.SourceType){
        switch source {
        case .photoLibrary, .savedPhotosAlbum:
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.selectionLimit = 10
            configuration.preferredAssetRepresentationMode = .current
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        case .camera:
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    }
        
    func fileSourceDidTap(){
        let documentController = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
        documentController.delegate = self
        documentController.allowsMultipleSelection = true
        documentController.modalPresentationStyle = .formSheet
        present(documentController, animated: true)
    }
    
    func extendByTime(_ seconds: TimeInterval) {
        let newFireDate = (typingTimer?.fireDate ?? Date()).addingTimeInterval(seconds)
        typingTimer?.fireDate = newFireDate
    }
    
    func openMessageInBrowser(messageID: Int) {
        let index = getMessageIndexById(messageId: messageID)
        if (index == -1) {
            return
        }

        guard messages.indices.contains(index) else { return }
        let message = messages[index]
        guard let file = message.file else { return }
        
        let _ = IQChannels.fileURL(file.id ?? "") { url, error in
            guard let url, error == nil else {
                let alert = UIAlertController(title: "Ошибка", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .cancel))
                self.present(alert, animated: true)
                return
            }
            
            UIApplication.shared.open(url)
        }
    }
    
    func getMessageIndexById(messageId: Int) -> Int {
        guard messageId != 0 else {
            return -1
        }

        for (index, message) in messages.enumerated() {
            if message.id == messageId {
                return index
            }
        }
        return -1
    }

    func getMyMessageByLocalId(localId: Int) -> Int {
        guard localId != 0 else {
            return -1
        }

        for (index, message) in messages.enumerated() {
            if message.isMy && message.localId == localId {
                return index
            }
        }
        return -1
    }
    
    func getMessageIndex(_ message: IQChatMessage) -> Int? {
        let index = getMessageIndexById(messageId: message.id)
        if index >= 0 {
            return index
        }
        if message.isMy {
            return getMyMessageByLocalId(localId: message.localId)
        }
        return nil
    }
    
    func isGroupStart(_ indexPath: IndexPath) -> Bool {
        let index = indexPath.row
        let message = messages[index]
        if index == 0 {
            return true
        }

        let prev = messages[index - 1]
        return prev.isMy != message.isMy
                || (prev.userId != nil && prev.userId != message.userId)
                || (message.createdAt - prev.createdAt) > 60000
    }

    func isGroupEnd(_ indexPath: IndexPath) -> Bool {
        let index = indexPath.row
        let message = messages[index]
        if index + 1 == messages.count {
            return true
        }

        let next = messages[index + 1]
        return next.isMy != message.isMy
                || (next.userId != nil && next.userId != message.userId)
                || (next.createdAt - message.createdAt) > 60000
    }
    
    func shouldDisplayMessageDate(_ indexPath: IndexPath) -> Bool {
        let index = indexPath.row
        guard index > 0 else { return true }
        let message = messages[index]
        let prev = messages[index - 1]
        
        let calendar = Calendar.current
        let messageDateComponents = calendar.dateComponents([.year, .month, .day], from: message.sentDate)
        let prevDateComponents = calendar.dateComponents([.year, .month, .day], from: prev.sentDate)
        
        return messageDateComponents.year != prevDateComponents.year ||
        messageDateComponents.month != prevDateComponents.month ||
        messageDateComponents.day != prevDateComponents.day
    }
    
    func contextMenuPreview(collectionView: UICollectionView, indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MessageContentCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cell.messageContainerView.bounds, cornerRadius: 16)
        let preview = UITargetedPreview(view: cell.messageContainerView, parameters: parameters)
        return preview
    }
    
    // MARK: - ACTIONS
    @objc func scrollDownDidTap() {
        messagesCollectionView.scrollToBottom(animated: true)
    }

    @objc func refresh() {
        if messagesLoaded {
            self.loadMoreMessages()
        } else {
            self.loadMessages()
        }
    }
    
    @objc func dismissKeyboard(){
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    @objc func attachmentDidTap(){
        messageInputBar.inputTextView.resignFirstResponder()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.present(alert, animated: true)
        }
    }
    
    @objc func onTick() {
        setTypingIndicatorViewHidden(true, animated: true)
        typingUser = nil
        typingTimer?.invalidate()
    }
}
