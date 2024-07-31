//
//  IQFileUploadRequest.swift
//  Pods
//
//  Created by Muhammed Aralbek on 19.05.2024.
//  
//

import Foundation

struct IQFileUploadRequest: Encodable {
    var name: String?
    var data: Data?
    var mimeType: String?
}
