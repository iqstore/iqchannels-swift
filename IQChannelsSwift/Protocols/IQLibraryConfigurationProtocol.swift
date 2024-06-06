//
//  IQLibraryConfigurationProtocol.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 27.05.2024.
//

import Foundation

public protocol IQLibraryConfigurationProtocol {
    /// Returns the main navigation controller of the library.
    func getViewController() -> UINavigationController?
    /// Configures the library with the provided configuration settings.
    func configure(_ config: IQChannelsConfig)
    /// Sets custom HTTP headers for network requests.
    func setCustomHeaders(_ headers: [String: String])
    /// Logs in the user with the specified login type.
    func login(_ loginType: IQLoginType)
    /// Logs out the current user and closes chat.
    func logout()
    /// Adds a listener to receive unread message notifications.
    func addUnread(listener: IQChannelsUnreadListenerProtocol)
    /// Removes a listener from receiving unread message notifications.
    func removeUnread(listener: IQChannelsUnreadListenerProtocol)
    /// Pushes the device token for push notifications.
    func pushToken(_ token: Data?)
}
