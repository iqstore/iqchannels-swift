//
//  IQNetworkManagerModels.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 27.05.2024.
//

import Foundation

struct ResponseCallback<T: Any> {
    var result: T?
    var error: Error?
}

typealias ResponseCallbackClosure<T: Any> = (T?, Error?) -> Void
typealias TaskIdentifierCallback = (Int) -> ()
