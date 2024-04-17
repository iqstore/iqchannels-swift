import Foundation

class IQSubscription {
    
    private let unsubscribeCompletion: () -> Void
    
    init() {
        self.unsubscribeCompletion = {}
    }
    
    init(unsubscribe: @escaping () -> Void) {
        self.unsubscribeCompletion = unsubscribe
    }
    
    func unsubscribe() {
        self.unsubscribeCompletion()
    }
}
