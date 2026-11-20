import XCTest
import SwiftUI
@testable import IQChannelsSwift

final class ExtensionsLogicTests: XCTestCase {

    func testUIColorHexComponents() {
        let red = UIColor(hex: "FF0000")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        red.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1, accuracy: 0.01)
        XCTAssertEqual(g, 0, accuracy: 0.01)
        XCTAssertEqual(b, 0, accuracy: 0.01)

        let green = UIColor(hex: "#00ff00")
        green.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0, accuracy: 0.01)
        XCTAssertEqual(g, 1, accuracy: 0.01)
        XCTAssertEqual(a, 1, accuracy: 0.01)
    }

    func testPaletteColorIsStablePerSameString() {
        let first = UIColor.paletteColorFromString(string: "Иван")
        let second = UIColor.paletteColorFromString(string: "Иван")
        XCTAssertEqual(first, second)

        let empty = UIColor.paletteColorFromString(string: "")
        XCTAssertEqual(empty, UIColor.paletteColorFromString(string: nil))

        XCTAssertNotEqual(UIColor.paletteColorFromString(string: "1"), UIColor.paletteColorFromString(string: "2"))
    }

    func testFormatToTimeUsesHoursMinutes() {
        let date = Date(timeIntervalSince1970: 1_764_000_000)
        let formatted = date.formatToTime()
        XCTAssertTrue(formatted.range(of: #"^\d{2}:\d{2}$"#, options: .regularExpression) != nil,
                      "ожидался формат HH:mm, получили \(formatted)")
    }

    func testFormatRelativelyReturnsNonEmptyString() {
        let formatted = Date().formatRelatively()
        XCTAssertFalse(formatted.isEmpty)
    }

    func testAsyncForEachPreservesOrder() async {
        var collected: [Int] = []
        await [1, 2, 3].asyncForEach { collected.append($0) }
        XCTAssertEqual(collected, [1, 2, 3])
    }

    func testRemoveElementsAtIndices() {
        var array = [10, 11, 12, 13, 14]
        let removed = array.remove(elementsAtIndices: [1, 3])

        XCTAssertEqual(array, [10, 12, 14])
        XCTAssertEqual(removed, [11, 13])
    }

    func testStringToAlignmentMapping() {
        XCTAssertEqual(stringToAlignment(stringAlignment: "left"), .leading)
        XCTAssertEqual(stringToAlignment(stringAlignment: "center"), .center)
        XCTAssertEqual(stringToAlignment(stringAlignment: "right"), .trailing)
        XCTAssertNil(stringToAlignment(stringAlignment: "justify"))
        XCTAssertNil(stringToAlignment(stringAlignment: nil))
    }

    func testGetChatItemsFiltersByChatToOpen() {
        let config = IQChannelsConfig(address: "https://x", channels: ["a", "b"],
                                      chatToOpen: (channel: "b", chatType: .chat))
        let manager = IQChannelsManager(configuration: config)

        let auth = IQClientAuth(client: IQClient(), session: nil, analytics: nil)
        let items = manager.getChatItems(from: [(channel: "a", auth: auth), (channel: "b", auth: auth)], config: config)

        XCTAssertEqual(items.map(\.channel), ["b"], "chatToOpen должен фильтровать только свой канал")
    }

    func testGetChatItemsWithoutPersonalManagerReturnsOnlyRegularChat() {
        let config = IQChannelsConfig(address: "https://x", channels: ["a"])
        let manager = IQChannelsManager(configuration: config)

        var client = IQClient()
        client.multiChatsInfo = IQMultiChatsInfo(personalManagerName: nil, channelName: nil, channelIconColor: nil,
                                                  enableForPersonalManagers: nil, enableChat: true, channelType: nil)
        let auth = IQClientAuth(client: client, session: nil, analytics: nil)

        let items = manager.getChatItems(from: [(channel: "a", auth: auth)], config: config)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.chatType, .chat)
    }

    func testGetChatItemsWithPersonalManagerReturnsChatAndManager() {
        let config = IQChannelsConfig(address: "https://x", channels: ["a"])
        let manager = IQChannelsManager(configuration: config)

        var client = IQClient()
        client.personalManagerID = 5
        client.multiChatsInfo = IQMultiChatsInfo(personalManagerName: nil, channelName: nil, channelIconColor: nil,
                                                  enableForPersonalManagers: nil, enableChat: true, channelType: nil)
        let auth = IQClientAuth(client: client, session: nil, analytics: nil)

        let items = manager.getChatItems(from: [(channel: "a", auth: auth)], config: config)

        XCTAssertEqual(Set(items.map(\.chatType)), [.chat, .manager],
                       "канал с персональным менеджером и включённым чатом даёт оба пункта")
    }

    func testGetChatItemsSkipsChannelWithoutClient() {
        let config = IQChannelsConfig(address: "https://x", channels: ["a"])
        let manager = IQChannelsManager(configuration: config)

        let auth = IQClientAuth(client: nil, session: nil, analytics: nil)
        let items = manager.getChatItems(from: [(channel: "a", auth: auth)], config: config)

        XCTAssertTrue(items.isEmpty)
    }
}

final class AttributeTextManagerLogicTests: XCTestCase {

    private let manager = AttributeTextManager.shared

    func testGetStringSyncReturnsPlainWithoutWebKitForPlainText() {
        let result = manager.getStringSync(from: "просто текст", textColor: .black, fontSize: 17,
                                           alingment: .leading, isBold: false, isItalic: false)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.0.string, "просто текст")
        XCTAssertTrue(result?.1.isEmpty ?? false)
    }

    func testGetStringSyncReturnsNilForMarkdownText() {
        let result = manager.getStringSync(from: "\\*жирный\\* текст", textColor: .black, fontSize: 17,
                                           alingment: .leading, isBold: false, isItalic: false)
        XCTAssertNil(result, "markdown не должен парситься синхронно — только отложенно через getString")
    }

    func testGetStringExtractsGenericHttpLinks() {
        let result = manager.getString(from: "смотри https://example.com/page здесь", textColor: .black,
                                       fontSize: 17, alingment: .leading, isBold: false, isItalic: false)
        XCTAssertTrue(result.1.contains { $0.0.contains("example.com") },
                      "обычная ссылка должна распознаваться как линк")
    }

    func testGetStringExtractsMarkdownLinks() {
        let result = manager.getString(from: "[сайт](https://example.com)", textColor: .black,
                                       fontSize: 17, alingment: .leading, isBold: false, isItalic: false)
        XCTAssertTrue(result.1.contains { $0.0.contains("example.com") })
        XCTAssertFalse(result.0.string.contains("("), "markdown-обёртка ссылки должна сниматься")
    }

    func testPlainResultsAreSharedBetweenSyncAndFullPaths() {
        let sync = manager.getStringSync(from: "кэш-тест", textColor: .black, fontSize: 17,
                                         alingment: .leading, isBold: false, isItalic: false)
        let full = manager.getString(from: "кэш-тест", textColor: .black,
                                     fontSize: 17, alingment: .leading, isBold: false, isItalic: false)
        XCTAssertNotNil(sync)
        XCTAssertEqual(sync?.0.string, full.0.string,
                       "plain-текст должен одинаково форматироваться в sync- и полной ветке")
    }

    func testPlainStringAppliesFontAndColor() {
        let attributed = manager.plainString(from: "текст", textColor: .red, fontSize: 20,
                                             alingment: .center, isBold: true, isItalic: false)
        XCTAssertEqual(attributed.string, "текст")

        let font = attributed.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        XCTAssertEqual(font?.fontDescriptor.symbolicTraits.contains(.traitBold), true)

        let color = attributed.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        color?.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        UIColor.red.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        XCTAssertEqual(r1, r2, accuracy: 0.01)
        XCTAssertEqual(g1, g2, accuracy: 0.01)
    }
}
