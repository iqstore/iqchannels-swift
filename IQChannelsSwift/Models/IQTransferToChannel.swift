//
//  IQTransferToChannel.swift
//  Pods
//
//  Created by Mikhail Zinkov on 06.12.2025.
//
//

import Foundation

struct IQTransferToChannel: Codable, Equatable, Identifiable, Hashable {
    var id: Int = 0
    var projectID: Int = 0
    var name: String?
    var title: String?
    var description: String?
    var createdAt: Int?
    var updatedAt: Int?
    var projectName: String?
    var chatTitle: String?
}
