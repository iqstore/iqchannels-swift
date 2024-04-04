import Foundation

extension NSError {
    
    static let IQErrorDomain = "ru.iqstore.iqchannels"
    static let IQErrorUserInfoKey = "ru.iqstore.error"

    static let IQErrorUnknown = 1
    static let IQErrorAppError = 2
    static let IQErrorClientError = 3

    class func iq_loggedOut() -> NSError {
        return iq_appError(withLocalizedDescription: NSLocalizedString("Logged out", comment: ""))
    }

    class func iq_appError(withLocalizedDescription text: String?) -> NSError {
        let descriptionText = text ?? NSLocalizedString("Unknown error", comment: "")
        return NSError(domain: IQErrorDomain, code: IQErrorAppError, userInfo: [NSLocalizedDescriptionKey: descriptionText])
    }

    class func iq_clientError() -> NSError {
        return iq_clientError(withLocalizedDescription: nil)
    }

    class func iq_clientError(withLocalizedDescription text: String?) -> NSError {
        let descriptionText = text ?? NSLocalizedString("Client error", comment: "")
        return NSError(domain: IQErrorDomain, code: IQErrorClientError, userInfo: [NSLocalizedDescriptionKey: descriptionText])
    }

    class func iq_withIQError(_ error: IQError?) -> NSError {
        let text = error?.text ?? NSLocalizedString("Unknown error", comment: "")
        let userInfo = [
            NSLocalizedDescriptionKey: text,
            IQErrorUserInfoKey: error as Any
        ] as [String : Any]

        return NSError(domain: IQErrorDomain, code: IQErrorAppError, userInfo: userInfo)
    }

    func iq_isAppError() -> Bool {
        return iq_appError != nil
    }

    func iq_isAuthError() -> Bool {
        guard iq_isAppError() else {
            return false
        }

        if let error = iq_appError, error.code == .unauthorized {
            return true
        }

        return false
    }

    var iq_appError: IQError? {
        return userInfo[NSError.IQErrorUserInfoKey] as? IQError
    }
}
