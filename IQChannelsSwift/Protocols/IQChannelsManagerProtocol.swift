//
//  IQChannelsManagerProtocol.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 27.05.2024.
//

import Foundation

protocol IQChannelsManagerProtocol {
    func login(_ loginType: IQLoginType)
    func logout()
    func setCustomHeaders(_ headers: [String: String])
    func setListViewModel(_ viewModel: IQChatListViewModel?)
    func pushToken(_ data: Data?)
    func unread(listener: IQChannelsUnreadListenerProtocol)
    func removeUnread(listener: IQChannelsUnreadListenerProtocol)
}
