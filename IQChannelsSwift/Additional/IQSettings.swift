import Foundation

class IQSettings {
    
    private let defaults: UserDefaults
    private let anonymousTokenKey = "iqchannels_anonymous_token"
    
    init() {
        self.defaults = UserDefaults.standard
    }
    
    func loadAnonymousToken() -> String? {
        return defaults.string(forKey: anonymousTokenKey)
    }
    
    func saveAnonymousToken(_ token: String?) {
        defaults.set(token, forKey: anonymousTokenKey)
        defaults.synchronize()
    }
    
    func deleteAnonymousToken() {
        defaults.removeObject(forKey: anonymousTokenKey)
        defaults.synchronize()
    }
}
