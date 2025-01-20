//
//  DataFile.swift
//  Pods
//
//  Created by Muhammed Aralbek on 23.05.2024.
//  
//

import Foundation

public struct DataFile: Codable, Equatable {
    let data: Data
    public let filename: String
    
    public init(data: Data, filename: String) {
        self.data = data
        self.filename = filename
    }
}
