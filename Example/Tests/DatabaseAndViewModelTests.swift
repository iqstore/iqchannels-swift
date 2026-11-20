import XCTest
@testable import IQChannelsSwift

final class DatabaseLogicTests: XCTestCase {

    private var uniqueLocalId: Int {
        Int(Date().timeIntervalSince1970 * 1000) + Int.random(in: 0...999)
    }

    func testChannelAndChatTypeRoundTripThroughDatabase() {
        let localId = uniqueLocalId
        var message = IQMessage(text: "канал-тест", chatType: .manager, channel: "support", clientID: 1, localID: localId, replyMessageID: nil)
        message.error = true

        IQDatabaseManager.shared.insertMessage(message.toDatabaseMessage())

        let restored = IQDatabaseManager.shared.getAllMessages().first { $0.localID == localId }
        XCTAssertNotNil(restored, "сообщение должно сохраниться")
        XCTAssertEqual(restored?.channel, "support", "канал должен переживать запись/чтение")
        XCTAssertEqual(restored?.chatType, "personal_manager")
        XCTAssertEqual(restored?.error, true)

        let back = IQMessage(from: restored!)
        XCTAssertEqual(back.channel, "support")
        XCTAssertEqual(back.chatType, .manager)

        IQDatabaseManager.shared.deleteMessageByLocalId(localId)
        XCTAssertNil(IQDatabaseManager.shared.getAllMessages().first { $0.localID == localId })
    }

    func testLegacyRowWithoutChannelParsesWithNilChannel() {
        let localId = uniqueLocalId
        let message = IQMessage(text: "легаси", chatType: .chat, channel: nil, clientID: 1, localID: localId, replyMessageID: nil)

        IQDatabaseManager.shared.insertMessage(message.toDatabaseMessage())

        let restored = IQDatabaseManager.shared.getAllMessages().first { $0.localID == localId }
        XCTAssertEqual(restored?.channel, nil)
        XCTAssertEqual(restored?.chatType, "regular")

        IQDatabaseManager.shared.deleteMessageByLocalId(localId)
    }

    func testReadMessageByChatIdMarksMessagesRead() {
        let localId = uniqueLocalId
        var message = IQMessage(text: "прочитанное", chatType: .chat, channel: "c1", clientID: 1, localID: localId, replyMessageID: nil)
        message.messageID = uniqueLocalId
        message.chatID = nil

        IQDatabaseManager.shared.insertMessage(message.toDatabaseMessage())

        let restoredBefore = IQDatabaseManager.shared.getAllMessages().first { $0.localID == localId }
        IQDatabaseManager.shared.readMessageByChatId(restoredBefore?.chatID)

        IQDatabaseManager.shared.deleteMessageByLocalId(localId)
    }
}

final class ViewModelLogicTests: XCTestCase {

    func testGetMessageFindsById() {
        let viewModel = IQChatDetailViewModel()
        var first = IQMessage(text: "первое", chatType: .chat, channel: nil, clientID: 1, localID: 1, replyMessageID: nil)
        first.messageID = 100
        var second = IQMessage(text: "второе", chatType: .chat, channel: nil, clientID: 1, localID: 2, replyMessageID: nil)
        second.messageID = 200
        viewModel.messages = [first, second]

        XCTAssertEqual(viewModel.getMessage(with: 200)?.text, "второе")
        XCTAssertEqual(viewModel.getMessage(with: 100)?.text, "первое")
        XCTAssertNil(viewModel.getMessage(with: 999))
        XCTAssertNil(viewModel.getMessage(with: nil))
    }

    func testShowMessageControlPublishesState() {
        let viewModel = IQChatDetailViewModel()
        let message = IQMessage(text: "текст", chatType: .chat, channel: nil, clientID: 1, localID: 1, replyMessageID: nil)

        viewModel.showMessageControl(MessageControlInfo(message: message, replyMessage: nil, frame: .zero))

        XCTAssertTrue(viewModel.messageControlShown)
        XCTAssertNotNil(viewModel.messageControlInfo)
    }
}
