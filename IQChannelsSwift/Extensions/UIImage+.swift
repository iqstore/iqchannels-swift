//
//  UIImage+.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 19.05.2024.
//

import UIKit

extension UIImage {
    
    convenience init?(name: String) {
        self.init(named: name, in: .libraryBundle(), compatibleWith: nil)
    }

    func dataRepresentation(withMaxSizeMB maxSizeMB: CGFloat = 10.0) -> Data? {
        let maxSizeBytes = maxSizeMB * 1024 * 1024
        var compressionQuality: CGFloat = 0.7
        var imageData = self.jpegData(compressionQuality: compressionQuality)
        
        while let data = imageData, CGFloat(data.count) > maxSizeBytes && compressionQuality > 0 {
            compressionQuality -= 0.1
            imageData = self.jpegData(compressionQuality: compressionQuality)
        }
                
        return imageData
    }
}

extension Data {
    
}
