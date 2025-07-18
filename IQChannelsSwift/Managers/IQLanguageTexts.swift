//
//  IQLanguageTexts.swift
//  IQChannelsSwift
//
//  Created by Mikhail Zinkov on 25.06.2025.
//

import SwiftUI

class IQLanguageTexts {
    
    static var model: IQLanguageTextsModel = IQLanguageTextsModel()
    
    private init() { }
    
    static func configure(_ data: Data?) {
        guard let data else {
            return
        }
        
        do {
            self.model = try JSONDecoder().decode(IQLanguageTextsModel.self, from: data)
        } catch {
            IQLog.error(message: "Ошибка декодирования языка: \(error)")
        }
        
//        print(model)
    }
}
