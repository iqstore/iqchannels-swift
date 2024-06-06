//
//  IQFile.swift
//  Pods
//
//  Created by Muhammed Aralbek on 19.05.2024.
//  
//

import Foundation

struct IQFile: Decodable, Equatable {
    
    // MARK: - PROPERTIES
    var id: String?
    var type: IQFileType?
    var name: String?
    var size: Int = 0
    var imageWidth: Int?
    var imageHeight: Int?
    
    // MARK: - LOCAL
    var dataFile: DataFile?
    var taskIdentifier: Int?
    var url: URL?
    var imagePreviewUrl: URL?
    
    // MARK: - INIT
    init(dataFile: DataFile) {
        id = UUID().uuidString
        type = dataFile.filename.contains("image.jpeg") ? .image : .file
        self.dataFile = dataFile
        name = dataFile.filename
        size = dataFile.data.count
    }
    

    // MARK: - COMPUTED
    var isFile: Bool {
        type == .file
    }
    
    var isImage: Bool {
        type == .image
    }
    
    var isLoading: Bool {
        url == nil
    }
    
    var convertedSize: String {
        let units = ["байт", "KБ", "MБ", "ГБ", "TБ", "ПБ"]
        var sizef = Double(size)
        var unit = 0

        while sizef >= 1024 && unit < (units.count - 1) {
            unit += 1
            sizef /= 1024
        }

        return String(format: "%.01f %@", sizef, units[unit])
    }
}
