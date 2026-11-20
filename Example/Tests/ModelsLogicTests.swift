import XCTest
@testable import IQChannelsSwift

final class ModelsLogicTests: XCTestCase {

    func testJSONDecoderMapsServerStyleKeys() throws {
        let json = """
        {"Id": 1785, "Read": false, "LocalId": 42, "ClientId": 7,
         "Text": "привет", "Payload": "text", "CreatedAt": 1764000000000}
        """.data(using: .utf8)!

        let message = try IQJSONDecoder().decode(IQMessage.self, from: json)

        XCTAssertEqual(message.messageID, 1785)
        XCTAssertEqual(message.isRead, false)
        XCTAssertEqual(message.localID, 42)
        XCTAssertEqual(message.clientID, 7)
        XCTAssertEqual(message.text, "привет")
        XCTAssertEqual(message.payload, .text)
        XCTAssertEqual(message.createdAt, 1764000000000)
    }

    func testJSONDecoderMapsFullyUppercaseKeysToCamelCase() throws {
        let json = """
        {"ID": 5, "READ": true, "ChatID": 3}
        """.data(using: .utf8)!

        let message = try IQJSONDecoder().decode(IQMessage.self, from: json)

        XCTAssertEqual(message.messageID, 5)
        XCTAssertEqual(message.isRead, true)
        XCTAssertEqual(message.chatID, 3)
    }

    func testMessageFormMapping() {
        var message = IQMessage(text: "текст", chatType: .manager, channel: "support", clientID: 5, localID: 99, replyMessageID: 12)
        message.fileID = "file-1"

        let form = IQMessageForm(message)

        XCTAssertEqual(form.localId, 99)
        XCTAssertEqual(form.text, "текст")
        XCTAssertEqual(form.fileId, "file-1")
        XCTAssertEqual(form.replyToMessageID, 12)
        XCTAssertEqual(form.chatType, .manager)
    }

    func testMergedPreservesLocalIdentityAndChannel() {
        var local = IQMessage(text: "hi", chatType: .manager, channel: "a", clientID: 1, localID: 100, replyMessageID: nil)
        local.error = true
        var server = local
        server.messageID = 1785
        server.text = "hi (echo)"

        let merged = local.merged(with: server)

        XCTAssertEqual(merged.messageID, 1785)
        XCTAssertEqual(merged.localID, 100)
        XCTAssertEqual(merged.channel, "a")
        XCTAssertFalse(merged.error, "серверное эхо сбрасывает ошибку")
        XCTAssertEqual(merged.text, "hi (echo)")
    }

    func testIsSurveyMessageOnlyForPollState() {
        var message = IQMessage(text: "x", chatType: .chat, channel: nil, clientID: 1, localID: 1, replyMessageID: nil)

        message.rating = IQRating(state: .pending)
        XCTAssertFalse(message.isSurveyMessage, "запрос оценки — не опрос, у него осмысленный текст")

        message.rating = IQRating(state: .poll)
        XCTAssertTrue(message.isSurveyMessage)

        message.rating = IQRating(state: .finished)
        XCTAssertFalse(message.isSurveyMessage)

        message.rating = nil
        XCTAssertFalse(message.isSurveyMessage)
    }

    func testIsPendingRatingMessageCoversPendingAndPoll() {
        var message = IQMessage(text: "x", chatType: .chat, channel: nil, clientID: 1, localID: 1, replyMessageID: nil)

        message.rating = IQRating(state: .pending)
        XCTAssertTrue(message.isPendingRatingMessage)

        message.rating = IQRating(state: .poll)
        XCTAssertTrue(message.isPendingRatingMessage)

        message.rating = IQRating(state: .rated)
        XCTAssertFalse(message.isPendingRatingMessage)
    }

    func testMessageTextForFilesAndRatingAndInvalid() {
        var message = IQMessage(text: "x", chatType: .chat, channel: nil, clientID: 1, localID: 1, replyMessageID: nil)

        var file = IQFile(dataFile: DataFile(data: Data([0]), filename: "doc.pdf"))
        file.type = .file
        file.name = "doc.pdf"
        message.file = file
        message.payload = .file
        XCTAssertEqual(message.messageText, "doc.pdf")

        message.file = nil
        message.payload = .invalid
        XCTAssertEqual(message.messageText, IQLanguageTexts.model.invalidMesssage ?? "Неподдерживаемый тип сообщения")

        message.payload = .text
        message.text = "обычный текст"
        XCTAssertEqual(message.messageText, "обычный текст")
    }

    func testIsMyAndSenderName() {
        var message = IQMessage(text: "x", chatType: .chat, channel: nil, clientID: 1, localID: 1, replyMessageID: nil)
        message.author = .client
        XCTAssertEqual(message.isMy, true)

        message.author = .user
        message.user = IQUser(id: 2, displayName: "Оператор", avatarID: nil, avatarURL: nil)
        XCTAssertEqual(message.isMy, false)
        XCTAssertEqual(message.senderName, "Оператор")

        message.author = .system
        XCTAssertEqual(message.senderName, IQLanguageTexts.model.senderNameSystem ?? "Система")
    }

    func testWithErrorAndWithReadKeepUIIdentity() {
        let message = IQMessage(text: "x", chatType: .chat, channel: nil, clientID: 1, localID: 7, replyMessageID: nil)

        let withErr = message.withError(true)
        XCTAssertTrue(withErr.error)
        XCTAssertEqual(withErr.id, message.id)

        let read = message.withRead(true)
        XCTAssertEqual(read.isRead, true)
        XCTAssertEqual(read.id, message.id)
    }

    func testLastMessageParseDateFormats() {
        let epochSeconds = LastMessage.parseDate("1764000000")
        XCTAssertNotNil(epochSeconds)
        XCTAssertEqual(epochSeconds!.timeIntervalSince1970, 1764000000, accuracy: 0.001)

        let epochMillis = LastMessage.parseDate("1764000000000")
        XCTAssertNotNil(epochMillis)
        XCTAssertEqual(epochMillis!.timeIntervalSince1970, 1764000000, accuracy: 0.001)

        let iso = LastMessage.parseDate("2026-11-20T10:00:00Z")
        XCTAssertNotNil(iso)

        let isoFractional = LastMessage.parseDate("2026-11-20T10:00:00.123Z")
        XCTAssertNotNil(isoFractional)

        XCTAssertNil(LastMessage.parseDate("не-дата"))
        XCTAssertNil(LastMessage.parseDate(""))
    }

    func testServerDateStringRoundTripsThroughParseDate() {
        let now = Date(timeIntervalSince1970: 1_764_000_000)
        let raw = LastMessage.serverDateString(from: now)

        let parsed = LastMessage.parseDate(raw)
        XCTAssertNotNil(parsed, "серверный формат \(raw) должен парситься обратно")
        if let parsed {
            XCTAssertEqual(parsed.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 1.0)
        }
    }

    func testIQChatTypeRawValues() {
        XCTAssertEqual(IQChatType.manager.rawValue, "personal_manager")
        XCTAssertEqual(IQChatType.chat.rawValue, "regular")
        XCTAssertEqual(IQChatType.info.rawValue, "info")
        XCTAssertEqual(IQChatType(rawValue: "regular"), .chat)
        XCTAssertNil(IQChatType(rawValue: "нет-такого"))
    }

    func testRatingStateInvalidRawValueDecodesAsInvalid() throws {
        let json = #"{"id": 1, "state": "какой-то-новый-стейт"}"#.data(using: .utf8)!
        let rating = try IQJSONDecoder().decode(IQRating.self, from: json)
        XCTAssertEqual(rating.state, .invalid)
    }

    func testNSErrorHelpersAndAuthErrorDetection() {
        let client = NSError.clientError("текст")
        XCTAssertEqual(client.domain, NSError.IQErrorDomain)
        XCTAssertEqual(client.code, NSError.IQErrorClientError)
        XCTAssertFalse(client.iqIsAuthError)

        let authError = IQError(code: .unauthorized, text: "нет доступа")
        let nsAuth = NSError(authError)
        XCTAssertTrue(nsAuth.iqIsAuthError)
        XCTAssertEqual(nsAuth.iqHTTPStatusCode, nil)

        let http = NSError.httpError(statusCode: 502, iqError: nil)
        XCTAssertEqual(http.iqHTTPStatusCode, 502)
        XCTAssertFalse(http.iqIsAuthError)

        let other = IQError(code: .forbidden, text: nil)
        XCTAssertFalse(NSError(other).iqIsAuthError)
    }
}
