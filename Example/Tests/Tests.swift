import XCTest
import IQChannelsSwift

class Tests: XCTestCase {
    
    var controller: IQChannelMessagesViewController!
    
    override func setUp() {
        super.setUp()
        controller = IQChannelMessagesViewController()
    }
    
    override func tearDown() {
        controller = nil
        super.tearDown()
    }
    
    func testViewControllerNotNil() {
        XCTAssertNotNil(controller.selectedIndexPathForMenu, "View controller should not be nil")
    }
    
    func testSenderExists() {
        XCTAssert(!controller.scrollsToBottomOnKeyboardBeginsEditing, "Pass")
    }
    
    func testExample() {
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
