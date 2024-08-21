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
        guard let originalImageData = self.jpegData(compressionQuality: 1) else {
            return nil
        }
        
        let maxSizeBytes = maxSizeMB * 1024 * 1024
        let imageSizeBytes = CGFloat(originalImageData.count)
        
        if imageSizeBytes <= maxSizeBytes {
            return originalImageData
        } else {
            let requiredQuality = maxSizeBytes / imageSizeBytes
            return self.jpegData(compressionQuality: requiredQuality)
        }
    }
}
