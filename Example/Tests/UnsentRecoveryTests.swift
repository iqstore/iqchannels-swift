import XCTest
@testable import IQChannelsSwift

final class UnsentRecoveryTests: XCTestCase {

    private final class NetworkMock: IQNetworkManagerProtocol {
        var token: String?

        var sendMessageResult: ((IQMessageForm) -> Error?)?
        var clientsIntegrationAuthResult: IQClientAuth?
        var loadMessagesResult: ([IQMessage], Bool, Int?, String, [IQLanguage]?, String?)?
        private(set) var sentForms: [IQMessageForm] = []
        private(set) var integrationAuthCalls = 0
        private(set) var listenRequests: [IQListenEventsRequest] = []
        var onOpenHandler: (() -> Void)?
        private(set) var resetSessionCalls = 0

        func isConnectedToEvents() -> Bool { true }
        func setCustomHeaders(_ headers: [String: String]) {}
        func resetSessionIfNeeded() { resetSessionCalls += 1 }
        func cancelTask(with taskIdentifier: Int) {}

        func listenToEvents(
            request: IQListenEventsRequest,
            onOpen: @escaping (() -> Void),
            callback: @escaping ResponseCallbackClosure<[IQChatEvent]>
        ) {
            listenRequests.append(request)
            onOpenHandler = onOpen
            eventsCallback = callback
        }

        var eventsCallback: ResponseCallbackClosure<[IQChatEvent]>?

        func listenToAdvancedUnread(callback: @escaping ResponseCallbackClosure<IQAdvancedUnreadResult>) {}
        func stopListenToEvents() {}
        func stopListenToAdvancedUnread() {}
        func pushToken(token: String) async -> Error? { nil }
        func sendReceivedEvent(_ messageIDs: [Int]) async -> Error? { nil }
        func sendReadEvent(_ messageIDs: [Int]) async -> Error? { nil }
        func sendTypingEvent() async -> Error? { nil }
        func sendAnalyticsEvent(_ event: IQAnalyticsEvent) async -> ResponseCallback<IQResult<IQEmptyResponse>> { .init() }
        func getFile(id: String) async throws -> IQFile? { nil }
        func loadMessages(request: IQLoadMessageRequest, getSettings: Bool, isInfoChat: Bool, language: String?) async -> ResponseCallback<([IQMessage], Bool, Int?, String, [IQLanguage]?, String?)> {
            .init(result: loadMessagesResult ?? ([], false, nil, "", nil, nil))
        }
        func getBlocker() async -> ResponseCallback<IQInfoChatSettings> { .init() }
        func rate(value: Int, ratingID: Int) async -> Error? { nil }
        func sendPoll(request: IQSendPollRequest) async -> Error? { nil }
        func finishPoll(ratingId: Int, pollId: Int, rated: Bool) async -> Error? { nil }
        func uploadFile(file: DataFile, taskIdentifierCallback: TaskIdentifierCallback?) async -> ResponseCallback<IQFile> { .init() }
        func sendMessage(form: IQMessageForm) async -> Error? {
            sentForms.append(form)
            return sendMessageResult?(form) ?? nil
        }
        func acceptProduct(form: IQProductForm) async -> Error? { nil }
        func declineProduct(form: IQProductForm) async -> Error? { nil }
        func clientsAuth(token: String) async -> ResponseCallback<IQClientAuth> { .init() }
        func clientsSignup() async -> ResponseCallback<IQClientAuth> { .init() }
        func clientsIntegrationAuth(credentials: String) async -> ResponseCallback<IQClientAuth> {
            integrationAuthCalls += 1
            return .init(result: clientsIntegrationAuthResult)
        }
        func getSignupGreetingSettings() async -> ResponseCallback<IQGreetingSettings> { .init() }
        func setLanguage(languageCode: String) async -> Error? { nil }
        func getAvailableLanguages() async -> ResponseCallback<[IQLanguage]> { .init() }
        func changeSegment(messageID: Int) async -> Error? { nil }
        func getAdvancedUnread(channels: [String]) async -> Error? { nil }
    }

    private func makeManager(mock: NetworkMock) -> IQChannelsManager {
        let config = IQChannelsConfig(address: "http://127.0.0.1:1", channels: ["support"])
        let manager = IQChannelsManager(configuration: config)
        manager.networkManagers["support"] = mock
        manager.authResults = [(channel: "support", auth: IQClientAuth(client: IQClient(), session: nil, analytics: nil))]
        return manager
    }

    private func waitForChatSelection() {
        let selected = expectation(description: "selectedChat settled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { selected.fulfill() }
        wait(for: [selected], timeout: 2)
    }

    private func makeStuckMessage(localID: Int, text: String) -> IQMessage {
        var message = IQMessage(text: text, chatType: .chat, channel: nil, clientID: 11, localID: localID, replyMessageID: nil)
        message.messageID = 0
        message.error = true
        return message
    }

    private func makeStuckMessage(localID: Int, text: String, chatType: IQChatType, channel: String) -> IQMessage {
        var message = IQMessage(text: text, chatType: chatType, channel: channel, clientID: 11, localID: localID, replyMessageID: nil)
        message.messageID = 0
        message.error = true
        return message
    }

    func testUnsentMessageFromOtherChatIsNotSentThroughCurrentChat() {
        let regularMock = NetworkMock()
        let pmMock = NetworkMock()
        let config = IQChannelsConfig(address: "http://127.0.0.1:1", channels: ["regular", "pm"])
        let manager = IQChannelsManager(configuration: config)
        manager.networkManagers["regular"] = regularMock
        manager.networkManagers["pm"] = pmMock
        let auth = IQClientAuth(client: IQClient(), session: nil, analytics: nil)
        manager.authResults = [
            (channel: "regular", auth: auth),
            (channel: "pm", auth: auth),
        ]

        waitForChatSelection()
        manager.selectedChat = ((channel: "regular", auth: auth), .chat)

        let settled = expectation(description: "selectedChat sink and loadMessages settled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { settled.fulfill() }
        wait(for: [settled], timeout: 4)

        let pmMessage = makeStuckMessage(localID: 301, text: "pm-failed", chatType: .manager, channel: "pm")
        manager.messages = [pmMessage]

        manager.resendMessage(pmMessage.withError(false))

        let sent = expectation(description: "manual resend settled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { sent.fulfill() }
        wait(for: [sent], timeout: 5)

        XCTAssertEqual(
            pmMock.sentForms.map(\.localId),
            [301],
            "Ручная переотправка pm-сообщения должна идти через менеджер своего канала"
        )
        XCTAssertEqual(
            regularMock.sentForms.count,
            0,
            "Неотправленное сообщение pm-чата не должно отправляться через текущий обычный чат"
        )
    }

    func testConcurrentAuthCallsAreSingleFlight() {
        let mock = NetworkMock()
        mock.clientsIntegrationAuthResult = IQClientAuth(
            client: IQClient(),
            session: IQClientSession(id: 1, clientId: 1, token: "token", integration: nil, integrationHash: nil, integrationCredentials: nil),
            analytics: nil
        )
        let config = IQChannelsConfig(address: "http://127.0.0.1:1", channels: ["support"])
        let manager = IQChannelsManager(configuration: config)
        manager.networkManagers["support"] = mock
        manager.networkStatusManager.status = .reachable

        var first: Bool?
        var second: Bool?
        manager.auth(.credentials("101")) { first = $0 }
        manager.auth(.credentials("101")) { second = $0 }

        let settled = expectation(description: "auth settled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { settled.fulfill() }
        wait(for: [settled], timeout: 5)

        XCTAssertEqual(
            mock.integrationAuthCalls, 1,
            "Параллельные вызовы auth не должны запускать вторую авторизацию — гонка на словарях ломала память (краш-группы 17238947001032442108, 4061562132654801282)"
        )
        XCTAssertEqual(first, true)
        XCTAssertEqual(second, true)
        XCTAssertEqual(manager.authResults.count, 1)
        XCTAssertFalse(manager.isAuthenticating)
    }

    func testLoadMessagesFillsHistorySettingsAndRestoresUnsent() {
        let mock = NetworkMock()
        var serverMessage = IQMessage(text: "ответ оператора", chatType: .chat, channel: "support", clientID: 11, localID: 500, replyMessageID: nil)
        serverMessage.messageID = 5000
        serverMessage.author = .user
        mock.loadMessagesResult = ([serverMessage], false, nil, "Чат с поддержкой",
                                   [IQLanguage(code: "ru", name: "Русский", isDefault: true, iconURL: nil)], "подзаголовок")

        let manager = makeManager(mock: mock)
        waitForChatSelection()

        manager.loadMessages(showLoading: true)

        let loaded = expectation(description: "messages loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { loaded.fulfill() }
        wait(for: [loaded], timeout: 5)

        XCTAssertTrue(
            manager.messages.contains { $0.messageID == 5000 && $0.text == "ответ оператора" },
            "история с сервера должна попасть в сообщения"
        )
        XCTAssertEqual(manager.chatSettingsCache["support"]?.label, "Чат с поддержкой")
        XCTAssertEqual(manager.chatSettingsCache["support"]?.subtitle, "подзаголовок")
    }

    private func makeEvent(_ type: IQChatEventType, id: Int = 1, message: IQMessage? = nil,
                           messages: [IQMessage]? = nil, messageID: Int? = nil,
                           user: IQUser? = nil, actor: IQAuthorType? = nil) -> IQChatEvent {
        IQChatEvent(id: id, type: type, chatID: nil, messageID: messageID, actor: actor,
                    clientID: nil, userID: nil, messages: messages, client: nil, user: user,
                    chat: nil, message: message, chatSubtitle: nil)
    }

    func testSseMessageCreatedAppendsIncomingMessage() {
        let mock = NetworkMock()
        let manager = makeManager(mock: mock)
        waitForChatSelection()

        manager.networkStatusChanged(.reachable)
        let sseStarted = expectation(description: "sse started")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { sseStarted.fulfill() }
        wait(for: [sseStarted], timeout: 3)

        var incoming = IQMessage(text: "новое входящее", chatType: .chat, channel: nil, clientID: 1, localID: 900, replyMessageID: nil)
        incoming.messageID = 3000
        incoming.author = .user
        mock.eventsCallback?([makeEvent(.messageCreated, id: 10, message: incoming)], nil)

        let applied = expectation(description: "event applied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { applied.fulfill() }
        wait(for: [applied], timeout: 3)

        XCTAssertTrue(
            manager.messages.contains { $0.messageID == 3000 },
            "SSE messageCreated должен добавить входящее сообщение"
        )
    }

    func testSseMessageCreatedMergesPendingByLocalId() {
        let mock = NetworkMock()
        let manager = makeManager(mock: mock)
        waitForChatSelection()

        manager.networkStatusChanged(.reachable)
        let sseStarted = expectation(description: "sse started")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { sseStarted.fulfill() }
        wait(for: [sseStarted], timeout: 3)

        var pending = IQMessage(text: "отправленное", chatType: .chat, channel: nil, clientID: 1, localID: 777, replyMessageID: nil)
        pending.author = .client
        manager.messages = [pending]

        var echo = pending
        echo.messageID = 3001
        mock.eventsCallback?([makeEvent(.messageCreated, id: 11, message: echo)], nil)

        let applied = expectation(description: "event applied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { applied.fulfill() }
        wait(for: [applied], timeout: 3)

        XCTAssertEqual(manager.messages.count, 1, "эхо должно мержиться с локальной копией, не дублироваться")
        XCTAssertEqual(manager.messages.first?.messageID, 3001)
        XCTAssertEqual(manager.messages.first?.localID, 777)
    }

    func testSseMessageReadMarksOwnMessageRead() {
        let mock = NetworkMock()
        let manager = makeManager(mock: mock)
        waitForChatSelection()

        manager.networkStatusChanged(.reachable)
        let sseStarted = expectation(description: "sse started")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { sseStarted.fulfill() }
        wait(for: [sseStarted], timeout: 3)

        var mine = IQMessage(text: "моё", chatType: .chat, channel: nil, clientID: 1, localID: 800, replyMessageID: nil)
        mine.messageID = 3002
        mine.author = .client
        mine.isRead = false
        mine.eventID = 1
        manager.messages = [mine]

        mock.eventsCallback?([makeEvent(.messageRead, id: 20, messageID: 3002)], nil)

        let applied = expectation(description: "event applied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { applied.fulfill() }
        wait(for: [applied], timeout: 3)

        XCTAssertEqual(manager.messages.first?.isRead, true, "messageRead должен ставить галочку прочтения")
    }

    func testSseDeleteMessagesRemovesFromHistory() {
        let mock = NetworkMock()
        let manager = makeManager(mock: mock)
        waitForChatSelection()

        manager.networkStatusChanged(.reachable)
        let sseStarted = expectation(description: "sse started")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { sseStarted.fulfill() }
        wait(for: [sseStarted], timeout: 3)

        var first = IQMessage(text: "1", chatType: .chat, channel: nil, clientID: 1, localID: 810, replyMessageID: nil)
        first.messageID = 3010
        var second = IQMessage(text: "2", chatType: .chat, channel: nil, clientID: 1, localID: 811, replyMessageID: nil)
        second.messageID = 3011
        manager.messages = [first, second]

        var deleted = second
        mock.eventsCallback?([makeEvent(.deleteMessages, id: 21, messages: [deleted])], nil)

        let applied = expectation(description: "event applied")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { applied.fulfill() }
        wait(for: [applied], timeout: 3)

        XCTAssertEqual(manager.messages.map(\.messageID), [3010], "delete-messages должен убирать сообщение из истории")
    }

    func testNetworkRecoveryDoesNotAutoSendUnsentMessages() {
        let mock = NetworkMock()
        let manager = makeManager(mock: mock)
        waitForChatSelection()
        manager.unsentMessages = [
            makeStuckMessage(localID: 101, text: "offline-1"),
            makeStuckMessage(localID: 102, text: "offline-2"),
        ]

        manager.networkStatusChanged(.reachable)

        let settled = expectation(description: "recovery cycle finished")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { settled.fulfill() }
        wait(for: [settled], timeout: 5)

        XCTAssertTrue(
            mock.sentForms.isEmpty,
            "Упавшие сообщения (красный восклицательный знак) не должны отправляться сами при восстановлении сети — только вручную"
        )
        XCTAssertEqual(
            manager.unsentMessages.count, 2,
            "Очередь unsent должна сохраниться: сообщения ждут ручной переотправки"
        )
    }

    func testSseOpenDoesNotAutoSendUnsentMessages() {
        let mock = NetworkMock()
        let manager = makeManager(mock: mock)
        waitForChatSelection()
        manager.unsentMessages = [makeStuckMessage(localID: 201, text: "stuck")]

        manager.networkStatusChanged(.reachable)

        let sseOpened = expectation(description: "sse listener started")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            mock.onOpenHandler?()
            sseOpened.fulfill()
        }
        wait(for: [sseOpened], timeout: 3)

        let settled = expectation(description: "settled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { settled.fulfill() }
        wait(for: [settled], timeout: 4)

        XCTAssertTrue(
            mock.sentForms.isEmpty,
            "SSE onOpen не должен авто-отправлять сообщения из unsent-очереди"
        )
    }

    func testDeletedMessageIsNotSentAfterRecovery() {
        let mock = NetworkMock()
        let manager = makeManager(mock: mock)
        waitForChatSelection()

        let stuck = makeStuckMessage(localID: 301, text: "will-be-deleted")
        manager.messages = [stuck]
        manager.unsentMessages = [stuck]

        manager.cancelSendMessage(stuck)

        XCTAssertTrue(manager.messages.isEmpty, "сообщение удалено из UI")
        XCTAssertTrue(manager.unsentMessages.isEmpty, "сообщение удалено из unsent-очереди")

        manager.networkStatusChanged(.reachable)

        let settled = expectation(description: "recovery finished")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { settled.fulfill() }
        wait(for: [settled], timeout: 5)

        XCTAssertTrue(
            mock.sentForms.isEmpty,
            "Удалённое сообщение не должно отправляться при восстановлении сети"
        )
    }

    func testReachableResetsOwnedSessions() {
        let mock = NetworkMock()
        let manager = makeManager(mock: mock)
        waitForChatSelection()

        manager.networkStatusChanged(.notReachable)
        manager.networkStatusChanged(.reachable)

        let reset = expectation(description: "session reset")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { reset.fulfill() }
        wait(for: [reset], timeout: 2)

        XCTAssertGreaterThanOrEqual(
            mock.resetSessionCalls, 1,
            "При возврате сети собственная URLSession должна пересоздаваться (сброс протухшего DNS/path-кэша)"
        )
    }

    func testNewMessagesSendAfterRecovery() {
        let mock = NetworkMock()
        let manager = makeManager(mock: mock)
        waitForChatSelection()

        manager.networkStatusChanged(.reachable)

        let recovered = expectation(description: "recovery cycle finished")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { recovered.fulfill() }
        wait(for: [recovered], timeout: 3)

        manager.sendMessage("после-восстановления", files: nil, replyToMessage: nil)

        let sent = expectation(description: "new message sent")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { sent.fulfill() }
        wait(for: [sent], timeout: 3)

        XCTAssertEqual(
            mock.sentForms.map { $0.text ?? "" },
            ["после-восстановления"],
            "Новые сообщения после возврата сети должны отправляться штатно (SDK-703)"
        )
        XCTAssertTrue(manager.unsentMessages.isEmpty)
    }
}
