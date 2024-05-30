//
//  IQChannelsUnreadListenerProtocol.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 24.05.2024.
//

import Foundation

public protocol IQChannelsUnreadListenerProtocol: AnyObject {
    var id: String { get }
    func iqChannelsUnreadDidChange(_ unread: Int)
}
