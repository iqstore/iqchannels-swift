import UIKit
import MessageKit
import SDWebImage
import InputBarAccessoryView

open class IQChannelMessagesViewController: MessagesViewController, UIGestureRecognizerDelegate {
    
    //MARK: - Views

    private var messagesIndicator = IQActivityIndicator()
    private var loginIndicator = IQActivityIndicator()
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
    private var messagesSub: IQSubscription?
    private var moreMessagesLoading: IQSubscription?    
    private var messagesLoaded: Bool = false
        
    // MARK: - LIFECYCLE
    public override func viewDidLoad() {
        messagesCollectionView = MessagesCollectionView(frame: .zero,
                                                        collectionViewLayout: CustomMessagesFlowLayout())
        
        super.viewDidLoad()
        
        setupIndicators()
        setupRefreshControl()
        setupNavBar()
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
    
    // MARK: - PRIVATE METHODS
    
    private func setupInputBar(){
        messageInputBar.delegate = self
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.backgroundColor = .init(hex: 0xF4F4F8)
        messageInputBar.inputTextView.placeholder = "Сообщение"
        messageInputBar.inputTextView.textContainerInset = .init(top: 9, left: 16, bottom: 9, right: 16)
        messageInputBar.inputTextView.placeholderLabelInsets.left += 2.5
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
    
    private func setupRefreshControl(){
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        messagesCollectionView.refreshControl = refreshControl
    }
    
    private func setupTypingTimer() {
        typingTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(onTick), userInfo: nil, repeats: false)
        if typingTimer == nil {
            typingTimer?.invalidate()
        }
    }
    
    private func setupIndicators(){
        view.addSubview(loginIndicator)
        view.addSubview(messagesIndicator)
        loginIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        messagesIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupNavBar() {
        navigationItem.title = "Сообщения"
    }
    
    private func setupCollectionView() {
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
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        let gr = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        gr.delegate = self
        messagesCollectionView.addGestureRecognizer(gr)
    }
    
    private func setupObservers(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(IQChannelMessagesViewController.inputTextViewDidBeginEditing),
                                               name: .UITextViewTextDidBeginEditing, object: messageInputBar.inputTextView)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(IQChannelMessagesViewController.inputTextViewDidEndEditing),
                                               name: .UITextViewTextDidEndEditing, object: messageInputBar.inputTextView)
    }
    
    @objc private func inputTextViewDidBeginEditing(){
        messageInputBar.setRightStackViewWidthConstant(to: 40, animated: true)
    }
    
    @objc private func inputTextViewDidEndEditing(){
        if messageInputBar.inputTextView.text.isEmpty {
            messageInputBar.setRightStackViewWidthConstant(to: .zero, animated: true)            
        }
    }
    
    @objc private func refresh() {
        if messagesLoaded {
            self.loadMoreMessages()
        } else {
            self.loadMessages()
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    @objc private func dismissKeyboard(){
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    @objc private func attachmentDidTap(){
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
        messageInputBar.inputTextView.resignFirstResponder()
        present(alert, animated: true)
    }
    
    private func photoSourceDidTap(source: UIImagePickerController.SourceType){
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc
    private func onTick() {
        setTypingIndicatorViewHidden(true, animated: true)
        typingUser = nil
        typingTimer?.invalidate()
    }
        
    private func fileSourceDidTap(){
        let documentController = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
        documentController.delegate = self
        documentController.modalPresentationStyle = .formSheet
        present(documentController, animated: true)
    }
    
    private func extendByTime(_ seconds: TimeInterval) {
        let newFireDate = (typingTimer?.fireDate ?? Date()).addingTimeInterval(seconds)
        typingTimer?.fireDate = newFireDate
    }
    
    private func openMessageInBrowser(messageID: Int) {
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
    
    private func getMessageIndexById(messageId: Int) -> Int {
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

    private func getMyMessageByLocalId(localId: Int) -> Int {
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
    
    private func getMessageIndex(_ message: IQChatMessage) -> Int? {
        let index = getMessageIndexById(messageId: message.id)
        if index >= 0 {
            return index
        }
        if message.isMy {
            return getMyMessageByLocalId(localId: message.localId)
        }
        return nil
    }
    
    private func isGroupStart(_ indexPath: IndexPath) -> Bool {
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

    private func isGroupEnd(_ indexPath: IndexPath) -> Bool {
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
    
    private func shouldDisplayMessageDate(_ indexPath: IndexPath) -> Bool {
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
                return cell
            }
            
            if message.file?.type == .file {
                let cell = messagesCollectionView.dequeueReusableCell(IQFilePreviewCell.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                cell.delegate = self
                return cell
            }
            
            let cell = messagesCollectionView.dequeueReusableCell(MyCustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        } else if case .text = message.kind {
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
        }
        return cell
    }

}

//MARK: - INPUT BAR DELEGATE
extension IQChannelMessagesViewController: InputBarAccessoryViewDelegate {
    
    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if !messagesLoaded {
            return
        }
        inputBar.inputTextView.text = nil
        IQChannels.sendText(text)
    }
    
    public func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        IQChannels.typing()
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
         let indicator = messagesCollectionView.dequeueReusableCell(TypingIndicatorCell.self, for: indexPath)
        indicator.insets.left = 40
        return indicator
    }
    
    public func textCell(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        let cell = messagesCollectionView.dequeueReusableCell(
          IQTimestampMessageCell.self,
          for: indexPath)
        cell.configure(with: message, at: indexPath, and: messagesCollectionView)
        cell.delegate = self
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
        
        return 20
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
        
        return NSAttributedString(string: displayName, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 11),
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
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: message.sentDate)
        return NSAttributedString(string: date, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 13),
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

        if let avatarImage = user.avatarImage {
            let avatar: Avatar = .init(image: avatarImage)
            avatarView.set(avatar: avatar)
        } else if let url = user.avatarURL {
            SDWebImageManager.shared.loadImage(with: url, progress: nil) { [weak self] image, _, _, _, _, _ in
                guard let self else { return }
                
                self.messages[indexPath.row].user?.avatarImage = image
                let index: Int
                if message.isMy {
                    index = self.getMyMessageByLocalId(localId: message.localId)
                } else {
                    index = self.getMessageIndexById(messageId: message.id)
                }
                messagesCollectionView.reloadItems(at: [.init(item: index, section: 0)])
            }
        } else {
            let initials = String((message.user?.name ?? "").prefix(1))
            let avatar: Avatar = .init(initials: initials)
            avatarView.set(avatar: avatar)
        }
        avatarView.backgroundColor = UIColor.paletteColorFromString(string: user.name)
    }

}

//MARK: - DATA PICKER DELEGATE
extension IQChannelMessagesViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate, UIDocumentPickerDelegate{
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        sendImage(image)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first,
        let data = try? Data.init(contentsOf: url) else { return }
        
        DispatchQueue.main.async {
            self.confirmDataSubmission(data: data, filename: url.lastPathComponent)
        }
    }
    
    public func confirmDataSubmission(data: Data, filename: String) {
        let alertController = UIAlertController(title: "Подтвердите отправку файла", message: filename, preferredStyle: .actionSheet)
        alertController.addAction(.init(title: "Отправить", style: .default, handler: { _ in
            self.sendData(data: data, filename: filename)
        }))
        alertController.addAction(.init(title: "Отмена", style: .cancel))
        messageInputBar.inputTextView.resignFirstResponder()
        present(alertController, animated: true)
    }
    
    public func sendData(data: Data, filename: String?) {
        IQChannels.sendData(data, filename: filename)
    }
    
    public func sendImage(_ image: UIImage) {
        IQChannels.sendImage(image, filename: nil)
    }
}

// MARK: - STATE LISTENER
extension IQChannelMessagesViewController: IQChannelsStateListener {
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
    }

    func iqAwaitingNetwork(_ state: IQChannelsState) {
        self.state = state
        
        loginIndicator.label.text = "Ожидание сети..."
        loginIndicator.startAnimating()
    }

    func iqAuthenticating(_ state: IQChannelsState) {
        self.state = state
        
        loginIndicator.label.text = "Авторизация..."
        loginIndicator.startAnimating()
    }

    func iqAuthenticated(_ state: IQChannelsState, client: IQClient) {
        self.state = state
        self.client = client
        
        loadMessages()
        loginIndicator.label.text = ""
        loginIndicator.stopAnimating()
    }
}

//MARK: - ChoiceDelegates
extension IQChannelMessagesViewController: IQCardCellDelegate, IQStackedSingleChoicesCellDelegate, IQSingleChoicesViewDelegate {
    
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
extension IQChannelMessagesViewController: IQChannelsMessagesListener, IQChannelsMoreMessagesListener {
    private func clearMessages() {
        messagesIndicator.stopAnimating()
        messagesSub?.unsubscribe()

        messages = []
        readMessages = []
        messagesSub = nil
        messagesLoaded = false
    }
    
    private func loadMoreMessages() {
        guard let client, messagesLoaded else { return }

        moreMessagesLoading = IQChannels.moreMessages(self)
        refreshControl.beginRefreshing()
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
        guard let client, messagesSub == nil, !messagesLoaded else { return }

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

    func iq(messages: [IQChatMessage]) {
        guard messagesSub != nil else { return }
        
        self.messages = messages
        readMessages = []
        messagesLoaded = true
        
        messagesIndicator.stopAnimating()
        refreshControl.endRefreshing()
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom()
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
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom()
    }

    func iq(messageSent message: IQChatMessage) {
        messages.append(message)
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom()
    }

    func iq(messageUpdated message: IQChatMessage) {
        guard let index = getMessageIndex(message) else {
            return
        }

        messages[index] = message
        var paths = [IndexPath]()
        paths.append(IndexPath(item: index, section: 0))
        if index > 0 {
            paths.append(IndexPath(item: index - 1, section: 0))
        }
        messagesCollectionView.reloadItems(at: paths)
    }
    
    func iq(messagesRemoved messages: [IQChatMessage]) {
        guard let messagesSub = messagesSub else { return }
        
        var remoteMessages = messages
        
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
        messagesCollectionView.scrollToBottom()
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
