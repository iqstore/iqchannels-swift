//
//  DataFile.swift
//  Pods
//
//  Created by Muhammed Aralbek on 23.05.2024.
//  
//

import Foundation

struct DataFile: Codable, Equatable {
    let data: Data
    let filename: String
}
