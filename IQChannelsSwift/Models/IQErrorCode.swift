//
//  IQErrorCode.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.05.2024.
//

import Foundation

enum IQErrorCode: String, Decodable {
    case unknown = ""
    case internalError = "internal_server_error"
    case badRequest = "bad_request"
    case notFound = "not_found"
    case forbidden
    case unauthorized
    case invalid
}
