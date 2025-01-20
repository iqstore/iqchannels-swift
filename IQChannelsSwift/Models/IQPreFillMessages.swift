//
//  IQPreFillMessages.swift
//  Pods
//
//  Created by Mikhail Zinkov on 19.01.2025.
//
//

import Foundation

public struct IQPreFillMessages: Codable, Equatable  {
    var textMsg: [String]? = nil
    var fileMsg: [DataFile]? = nil
    
    public init(textMsg: [String]?, fileMsg: [DataFile]?) {
        self.textMsg = textMsg
        self.fileMsg = fileMsg
    }
}
