import Foundation

class IQHttpRequest {
    
    private var cancellation: (() -> Void)?
    
    init() {
        self.cancellation = {}
    }
    
    init(cancellation: @escaping () -> Void) {
        self.cancellation = cancellation
    }
    
    func cancel() {
        self.cancellation?()
    }
}
