//
//  IQProduct.swift
//  Pods
//
//  Created by Mikhail Zinkov on 20.04.2026.
//
//

import Foundation

struct IQProduct: Codable, Equatable, Identifiable, Hashable {
    var id: Int = 0
    var periodicPaymentPrice: Int = 0
    var periodicPaymentType: String?
}
