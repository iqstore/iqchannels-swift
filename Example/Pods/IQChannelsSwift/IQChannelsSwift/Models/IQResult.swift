//
//  IQResult.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.05.2024.
//

import Foundation

struct IQResult<T: Decodable> {
    
    let value: T?
    let relations: IQRelationMap?

    init(value: T?, relations: IQRelationMap?) {
        self.value = value
        self.relations = relations
    }

    init() {
        self.init(value: nil, relations: IQRelationMap())
    }
}
