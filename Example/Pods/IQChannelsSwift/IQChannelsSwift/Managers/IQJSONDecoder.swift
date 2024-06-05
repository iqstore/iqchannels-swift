//
//  IQJSONDecoder.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 11.05.2024.
//

import UIKit

class IQJSONDecoder: JSONDecoder {
    
    override init() {
        super.init()
        keyDecodingStrategy = .custom { keys in
            let lastKey = keys.last!
            
            if lastKey.stringValue == lastKey.stringValue.uppercased() {
                return IQKey(stringValue: lastKey.stringValue.lowercased())!
            }
            
            guard let firstCharacter = lastKey.stringValue.first else { return lastKey }
            
            var modifiedKey = firstCharacter.lowercased() + lastKey.stringValue.dropFirst()
            modifiedKey = modifiedKey.replacingOccurrences(of: "Id", with: "ID")
            return IQKey(stringValue: modifiedKey) ?? lastKey
        }
    }
    
}
