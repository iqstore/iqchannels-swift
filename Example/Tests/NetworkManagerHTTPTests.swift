import XCTest
@testable import IQChannelsSwift

final class StubURLProtocol: URLProtocol {

    nonisolated(unsafe) static var handler: ((URLRequest) -> (Int, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else { return }
        let (status, data) = handler(request)
        let response = HTTPURLResponse(url: request.url!, statusCode: status,
                                       httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

final class NetworkManagerHTTPTests: XCTestCase {

    private func makeManager() -> IQNetworkManager {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        let manager = IQNetworkManager(address: "https://stub.local", channel: "support",
                                       urlSession: URLSession(configuration: config))
        manager.token = "token-1"
        return manager
    }

    override func tearDown() {
        StubURLProtocol.handler = nil
        super.tearDown()
    }

    func testSendMessageBuildsRequestWithClientAuthHeader() async {
        nonisolated(unsafe) var captured: URLRequest?
        StubURLProtocol.handler = { request in
            captured = request
            return (200, #"{"OK": true}"#.data(using: .utf8)!)
        }

        let error = await makeManager().sendMessage(form: IQMessageForm(
            IQMessage(text: "привет", chatType: .chat, channel: "support", clientID: 1, localID: 7, replyMessageID: nil)
        ))

        XCTAssertNil(error)
        XCTAssertEqual(captured?.url?.absoluteString, "https://stub.local/public/api/v1/chats/channel/send/support")
        XCTAssertEqual(captured?.httpMethod, "POST")
        XCTAssertEqual(captured?.value(forHTTPHeaderField: "Authorization"), "Client token-1",
                       "схема авторизации — Client <token>, не Bearer")
    }

    func testSendMessageMapsServerErrorEnvelope() async {
        StubURLProtocol.handler = { _ in
            (200, #"{"OK": false, "Error": {"Code": "unauthorized", "Text": "сессия истекла"}}"#.data(using: .utf8)!)
        }

        let error = await makeManager().sendMessage(form: IQMessageForm(
            IQMessage(text: "x", chatType: .chat, channel: nil, clientID: 1, localID: 1, replyMessageID: nil)
        ))

        XCTAssertNotNil(error)
        XCTAssertEqual(error?.iqIsAuthError, true, "unauthorized из конверта должен распознаваться как auth-ошибка")
    }

    func testLoadMessagesDecodesResultArray() async {
        StubURLProtocol.handler = { request in
            XCTAssertTrue(request.url!.path.contains("/chats/channel/messages/support"))
            let body = """
            {"OK": true, "Result": [{"Id": 9, "Text": "история", "Payload": "text",
              "UserId": 3, "CreatedAt": 1764000000000}]}
            """
            return (200, body.data(using: .utf8)!)
        }

        let response = await makeManager().loadMessages(request: .init(chatType: .chat), getSettings: false,
                                                        isInfoChat: false, language: nil)

        XCTAssertNil(response.error)
        let messages = response.result?.0 ?? []
        XCTAssertEqual(messages.first?.messageID, 9)
        XCTAssertEqual(messages.first?.text, "история")
        XCTAssertEqual(messages.first?.userID, 3)
    }

    func testHTTPFailureProducesStatusCodeError() async {
        StubURLProtocol.handler = { _ in
            (500, #"{"OK": false}"#.data(using: .utf8)!)
        }

        let error = await makeManager().sendMessage(form: IQMessageForm(
            IQMessage(text: "x", chatType: .chat, channel: nil, clientID: 1, localID: 1, replyMessageID: nil)
        ))

        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.code, NSError.IQErrorClientError)
        XCTAssertEqual((error as NSError?)?.domain, NSError.IQErrorDomain)
    }
}
