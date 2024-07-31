//
//  IQStorageManager.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.05.2024.
//

import Foundation

class IQStorageManager {
    
    private let defaults: UserDefaults = .standard
    private let anonymousTokenKey = "iqchannels_anonymous_token"
    
    /// Key is channel, value is token
    var anonymousTokens: [String: String]? {
        get {
            defaults.dictionary(forKey: anonymousTokenKey) as? [String: String]
        } set {
            defaults.set(newValue, forKey: anonymousTokenKey)
            defaults.synchronize()
        }
    }
    
}
