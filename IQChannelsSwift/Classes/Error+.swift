import Foundation

extension Error {
    
//    static let IQErrorDomain = "ru.iqstore.iqchannels"
//    static let IQErrorUserInfoKey = "ru.iqstore.error"
//
//    static let IQErrorUnknown = 1
//    static let IQErrorAppError = 2
//    static let IQErrorClientError = 3

    static func iqLoggedOut() -> Error {
        return iqAppError(withLocalizedDescription: NSLocalizedString("Logged out", comment: ""))
    }

    static func iqAppError(withLocalizedDescription text: String?) -> Error {
        let descriptionText = text ?? NSLocalizedString("Unknown error", comment: "")
        return NSError(domain: "ru.iqstore.iqchannels", code: 2, userInfo: [NSLocalizedDescriptionKey: descriptionText])
    }

    static func iqClientError() -> Error {
        return iqClientError(withLocalizedDescription: nil)
    }

    static func iqClientError(withLocalizedDescription text: String?) -> Error {
        let descriptionText = text ?? NSLocalizedString("Client error", comment: "")
        return NSError(domain: "ru.iqstore.iqchannels", code: 3, userInfo: [NSLocalizedDescriptionKey: descriptionText])
    }

    static func iqWithIQError(_ error: IQError?) -> Error {
        let text = error?.text ?? NSLocalizedString("Unknown error", comment: "")
        let userInfo = [
            NSLocalizedDescriptionKey: text,
            "ru.iqstore.error": error as Any
        ] as [String : Any]

        return NSError(domain: "ru.iqstore.iqchannels", code: 2, userInfo: userInfo)
    }

    func iqIsAppError() -> Bool {
        return iqAppError != nil
    }

    func iqIsAuthError() -> Bool {
        guard iqIsAppError() else {
            return false
        }

        if let error = iqAppError, error.code == .unauthorized {
            return true
        }

        return false
    }

    var iqAppError: IQError? {
        return (self as NSError).userInfo["ru.iqstore.error"] as? IQError
    }
}
