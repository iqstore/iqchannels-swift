//
//  Style.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 29.05.2024.
//

import Foundation

class Style {
    
    static var model: StyleModel?
    
    private init() { }
    
    static func configure(_ data: Data?) {
        guard let data else { return }
        
        self.model = try? JSONDecoder().decode(StyleModel.self, from: data)
    }
    
}
