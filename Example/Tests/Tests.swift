import XCTest
@testable import IQChannelsSwift

class Tests: XCTestCase {
    
    var library: IQLibraryConfiguration!
    
    override func setUp() {
        super.setUp()
        let config = IQChannelsConfig(address: "https://sandbox.iqstore.ru/", channels: ["support", "finance"])
        library = IQLibraryConfiguration()
        library.configure(config)
        
        let loginType = IQLoginType.credentials("101")
        library.login(loginType)
    }
    
    override func tearDown() {
        library = nil
        super.tearDown()
    }
    
    // Test for getViewController method
    func testGetViewController() {
        let navigationController = library.getViewController()
        XCTAssertNotNil(navigationController, "Navigation Controller should not be nil")
    }
    
    // Test for configure method
    func testConfigure() {
        let config = IQChannelsConfig(address: "https://example2.com", channels: ["channel2"])
        library.configure(config)
        // Asserting configuration settings
        XCTAssertEqual(config.address, "https://example2.com", "Configuration address should be https://example2.com")
    }
    
    // Test for setCustomHeaders method
    func testSetCustomHeaders() {
        let headers = ["Authorization": "Bearer token"]
        library.setCustomHeaders(headers)
        // Asserting headers are set
        let networkManager = (library.channelManager as! IQChannelsManager).networkManagers.first?.value as! IQNetworkManager
        XCTAssertEqual(networkManager.customHeaders?["Authorization"], "Bearer token", "Custom headers should be set correctly")
    }
        
    // Test for addUnread listener method
    func testAddUnreadListener() {
        let unreadListener = MockUnreadListener()
        library.addUnread(listener: unreadListener)
        let listeners = (library.channelManager as! IQChannelsManager).unreadListeners
        XCTAssertTrue(listeners.contains { $0.id == unreadListener.id }, "Unread listener should be added")
    }
    
    // Test for removeUnread listener method
    func testRemoveUnreadListener() {
        let unreadListener = MockUnreadListener()
        library.addUnread(listener: unreadListener)
        library.removeUnread(listener: unreadListener)
        let listeners = (library.channelManager as! IQChannelsManager).unreadListeners
        XCTAssertFalse(listeners.contains { $0.id == unreadListener.id }, "Unread listener should be removed")
    }
    
    // Test for pushToken method
    func testPushToken() {
        let token = Data([0x01, 0x02, 0x03, 0x04])
        library.pushToken(token)
        // Add assertions based on expected behavior after pushing token
    }
    
    // Test for logout method
    func testLogout() {
        library.logout()
        // Add assertions based on expected behavior after logout
    }

}

// Mock Unread Listener
class MockUnreadListener: IQChannelsUnreadListenerProtocol {
    var id: String = UUID().uuidString
        
    func iqChannelsUnreadDidChange(_ unread: Int) {
        // Mock implementation
    }
}
