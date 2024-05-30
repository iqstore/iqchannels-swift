//
//  PHPickerResult+.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 22.05.2024.
//

import PhotosUI

extension PHPickerResult {
    func data() async -> Data? {
        await withUnsafeContinuation { continuation in
            let itemProvider = itemProvider
            
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier){
                itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.gif.identifier) { data, _ in
                    continuation.resume(returning: data)
                }
            } else if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        continuation.resume(returning: image.dataRepresentation())
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.webP.identifier){
                itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.webP.identifier) { data, _ in
                    guard let data, let image = UIImage(data: data) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    continuation.resume(returning: image.dataRepresentation())
                }
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
}
