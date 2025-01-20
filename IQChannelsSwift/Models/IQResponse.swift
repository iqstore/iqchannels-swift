//
//  IQResponse.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.05.2024.
//

import Foundation

struct IQResponse<T: Decodable>: Decodable {
    
    var ok: Bool
    var error: IQError?
    var result: T?
    var data: T?
    var rels: IQRelations?

}
