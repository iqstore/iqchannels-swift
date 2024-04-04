import Foundation

class IQTimeout {
    
    static func seconds(withAttempt attempt: Int) -> Int {
        guard attempt > 0 else {
            return 0
        }
        
        switch attempt {
            case 1:
                return 1
            case 2:
                return 2
            case 3:
                return 5
            case 4:
                return 10
            case 5:
                return 15
            case 6:
                return 20
            default:
                return 30
        }
    }
    
    static func time(withAttempt attempt: Int) -> DispatchTime {
        let seconds = self.seconds(withAttempt: attempt)
        return self.time(withTimeoutSeconds: seconds)
    }
    
    static func time(withTimeoutSeconds seconds: Int) -> DispatchTime {
        return DispatchTime.now() + Double(seconds)
    }
}
