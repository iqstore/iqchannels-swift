import XCTest
import CoreLocation
import IQChannelsSwift
import MessageKit

class Tests: XCTestCase {
    
    // MARK: - PROPERTIES
    private var layoutDelegate = MockLayoutDelegate()
    private var controller: IQChannelMessagesViewController!
    
    // MARK: - SETUP
    override func setUp() {
        super.setUp()
        controller = IQChannelMessagesViewController()
        controller.messagesCollectionView.messagesLayoutDelegate = layoutDelegate
        controller.messagesCollectionView.messagesDisplayDelegate = layoutDelegate
        _ = controller.view
        controller.beginAppearanceTransition(true, animated: true)
        controller.endAppearanceTransition()
        controller.view.layoutIfNeeded()
    }
    
    override func tearDown() {
        controller = nil
        super.tearDown()
    }
    
    // MARK: - PRIVATE METHODS
    private func makeMessages(for senders: [MockUser]) -> [MessageType] {
        [
            MockMessage(text: "Text 1", user: senders[0], messageId: "test_id_1"),
            MockMessage(text: "Text 2", user: senders[1], messageId: "test_id_2"),
        ]
    }
    
    // MARK: - TESTS
    func testChannelConfigCopy() {
        let config = IQChannelsConfig(address: "https://sandbox.iqstore.ru/",
                                      channel: "support")
        XCTAssertNotNil(config.copy() as? IQChannelsConfig)
        XCTAssertNotEqual(config, config.copy() as! IQChannelsConfig)
    }
    
    func testChannelConfigJson() {
        let config = IQChannelsConfig(address: "https://sandbox.iqstore.ru/",
                                      channel: "support")
        XCTAssertNotNil(config.copy() as? IQChannelsConfig)
        XCTAssertEqual(config.toJSONObject()["address"] as! String, "https://sandbox.iqstore.ru/")
        XCTAssertEqual(config.toJSONObject()["channel"] as! String, "support")
        XCTAssertEqual(config.toJSONObject()["disableUnreadBadge"] as! Bool, false)
    }
    
    func testNumberOfSectionWithoutDataIsOne() {
        let messagesDataSource = MockMessagesDataSource()
        controller.messagesCollectionView.messagesDataSource = messagesDataSource
        
        XCTAssertEqual(controller.messagesCollectionView.numberOfSections, 1)
    }
    
    func testNumberOfSectionIsNumberOfMessages() {
        let messagesDataSource = MockMessagesDataSource()
        controller.messagesCollectionView.messagesDataSource = messagesDataSource
        messagesDataSource.messages = makeMessages(for: messagesDataSource.senders)
        
        controller.messagesCollectionView.reloadData()
        
        let count = controller.messagesCollectionView.numberOfSections
        let expectedCount = messagesDataSource.numberOfSections(in: controller.messagesCollectionView)
        
        XCTAssertEqual(count, expectedCount)
    }
    
    func testNumberOfItemInSectionIsOne() {
        let messagesDataSource = MockMessagesDataSource()
        controller.messagesCollectionView.messagesDataSource = messagesDataSource
        messagesDataSource.messages = makeMessages(for: messagesDataSource.senders)
        
        controller.messagesCollectionView.reloadData()
        
        XCTAssertEqual(controller.messagesCollectionView.numberOfItems(inSection: 0), 1)
        XCTAssertEqual(controller.messagesCollectionView.numberOfItems(inSection: 1), 1)
    }
}


private class MockLayoutDelegate: MessagesLayoutDelegate, MessagesDisplayDelegate {
    func heightForLocation(message _: MessageType, at _: IndexPath, with _: CGFloat, in _: MessagesCollectionView) -> CGFloat {
        0.0
    }
    
    func heightForMedia(message _: MessageType, at _: IndexPath, with _: CGFloat, in _: MessagesCollectionView) -> CGFloat {
        10.0
    }
    
    func snapshotOptionsForLocation(
        message _: MessageType,
        at _: IndexPath,
        in _: MessagesCollectionView)
    -> LocationMessageSnapshotOptions
    {
        LocationMessageSnapshotOptions()
    }
}
