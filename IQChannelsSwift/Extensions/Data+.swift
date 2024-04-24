//
//  Data+.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 23.04.2024.
//

import Foundation
import UIKit
import PhotosUI

extension NSItemProvider {
    func loadImage(completion: @escaping (UIImage?, Error?) -> Void) {
        if canLoadObject(ofClass: UIImage.self) {
            // Handle UIImage type
            loadObject(ofClass: UIImage.self) { image, error in
                guard let resultImage = image as? UIImage else {
                    completion(nil, error)
                    return
                }
                completion(resultImage, error)
            }
        } else if hasItemConformingToTypeIdentifier(UTType.webP.identifier) {
            // Handle WebP Image
            loadDataRepresentation(forTypeIdentifier: UTType.webP.identifier) { data, error in
                guard let data,
                      let webpImage = UIImage(data: data) else {
                    completion(nil, error)
                    return
                }
                completion(webpImage, error)
            }
        } else {
            completion(nil, nil)
        }
    }
}
