//
//  IQLanguage.swift
//  IQChannelsSwift
//
//  Created by Zinkov Mikhail on 25.06.2025.
//

import Foundation
import SwiftUI

struct IQLanguage: Decodable {
    let code: String?
    let name: String?
    let isDefault: Bool?
    let iconURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case isDefault = "default"
        case iconURL = "icon_url"
    }
}

struct IQLanguageResponse: Decodable {
    let languages: [IQLanguage]?
}

