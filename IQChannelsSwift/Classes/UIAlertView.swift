//
//  UIAlertView.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 04.04.2024.
//

import UIKit

extension UIAlertController {
    
    convenience init(error: Error) {
        self.init(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        addAction(.init(title: "OK", style: .cancel))
    }

}
