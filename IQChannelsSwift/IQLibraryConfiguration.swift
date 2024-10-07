//
//  IQLibraryConfiguration.swift
//  IQChannelsSwift-IQChannelsSwift
//
//  Created by Muhammed Aralbek on 06.05.2024.
//

import Foundation
import UIKit

public class IQLibraryConfiguration: IQLibraryConfigurationProtocol {
    
    var channelManager: (IQChannelsManagerProtocol & IQChannelsManagerListOutput)?
    
    public init () { }
    
    public func getViewController() -> UINavigationController? {
        guard let channelManager else { return nil }
        
        let viewModel = IQChatListViewModel()
        channelManager.setListViewModel(viewModel)
        let list = IQChatListViewController(viewModel: viewModel, output: channelManager)
        
        let navigationController = UINavigationController(rootViewController: list)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.modalTransitionStyle = .coverVertical

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundImage = UIImage()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.shadowColor = .clear

        navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController.navigationBar.compactAppearance = navigationBarAppearance
        navigationController.navigationBar.standardAppearance = navigationBarAppearance
        
        return navigationController
    }
    
    public func setCustomHeaders(_ headers: [String : String]) {
        channelManager?.setCustomHeaders(headers)
    }
    
    public func configure(_ config: IQChannelsConfig) {        
        Style.configure(config.styleJson)
        if channelManager == nil {
            channelManager = IQChannelsManager(config: config)
        }
    }
    
    public func setNewJSON(_ json: Data?) {
        Style.configure(json)
    }
    
    public func login(_ loginType: IQLoginType) {
        channelManager?.login(loginType)
    }
    
    public func logout() {
        channelManager?.logout()
    }
    
    public func addEvent(listener: any IQChannelsEventListenerProtocol) {
        channelManager?.addEvent(listener: listener)
    }
    
    public func removeEventListener() {
        channelManager?.removeEventListener()
    }

    public func addUnread(listener: any IQChannelsUnreadListenerProtocol) {
        channelManager?.addUnread(listener: listener)
    }
    
    public func removeUnread(listener: any IQChannelsUnreadListenerProtocol) {
        channelManager?.removeUnread(listener: listener)
    }
    
    public func pushToken(_ token: Data?) {
        channelManager?.pushToken(token)
    }
    
    public func setTheme(_ styleType: IQTheme) {
        Style.newTheme(styleType)
    }
    
}
