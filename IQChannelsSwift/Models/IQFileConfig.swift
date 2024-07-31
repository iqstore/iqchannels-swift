//
//  IQFileConfig.swift
//  Pods
//
//  Created by Muhammed Aralbek on 21.07.2024.
//  
//

import Foundation

struct IQFileConfig: Decodable {
    let maxFileSizeMb: Int?
    let maxImageHeight: Int?
    let maxImageWidth: Int?
    let allowedExtensions: [String]?
    let forbiddenExtensions: [String]?
}
