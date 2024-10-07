//
//  Style.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 29.05.2024.
//

import SwiftUI

class Style {
    
    static var model: StyleModel?
    
    private init() { }
    
    static func configure(_ data: Data?) {
        guard let data else {
            self.model = nil
            return
        }
                
        self.model = try? JSONDecoder().decode(StyleModel.self, from: data)
    }
    
    static func newTheme(_ styleType: IQTheme) {
        switch styleType {
        case .dark:
            self.model?.theme = .dark
        case .light:
            self.model?.theme = .light
        case .system:
            self.model?.theme = .system
        }
    }
    
    static func getColor(theme: Theme?) -> Color? {
        guard let theme,
              let light = theme.light,
              let dark = theme.dark else { return nil }
        
        switch model?.theme {
        case .light:
            return Color(hex: light)
        case .dark:
            return Color(hex: dark)
        default:
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return Color(hex: dark)
            } else {
                return Color(hex: light)
            }
        }
    }
    
    static func getUIColor(theme: Theme?) -> UIColor? {
        guard let theme,
              let light = theme.light,
              let dark = theme.dark else { return nil }
        
        switch model?.theme {
        case .light:
            return UIColor(hex: light)
        case .dark:
            return UIColor(hex: dark)
        default:
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return UIColor(hex: dark)
            } else {
                return UIColor(hex: light)
            }
        }
    }
}
