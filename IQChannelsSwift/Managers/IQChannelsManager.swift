//
//  IQChannelsManager.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 08.05.2024.
//

import Foundation
import Combine
import SDWebImage

class IQChannelsManager: IQChannelsManagerProtocol {
    
    //MARK: - Typealiases
    typealias AuthResult = (channel: String, auth: IQClientAuth)
    
    //MARK: - Models
    @Published var selectedChat: (auth: AuthResult, chatType: IQChatType)?
    @Published var authResults = [AuthResult]()
    @Published var state: IQChannelsState = .awaitingNetwork
    @Published var messages: [IQMessage] = []
    @Published var detailViewModel: IQChatDetailViewModel?
    @Published var systemChat: Bool = false
    var config: IQChannelsConfig
    var listViewModel: IQChatListViewModel?
    var baseViewModels: [IQBaseViewModel] {
        [listViewModel, detailViewModel].compactMap { $0 }
    }
    var unsentMessages = [IQMessage]()
    var readMessages = Set<Int>()
    var authAttempt = 0
    var lastLocalID = 0
    var loginType: IQLoginType?
    var typingTimer: Timer?
    var isLoadingOldMessages = false
    var typingSentDate: Date?
    var didSendAttachments = false
    var fileLimit: IQFileConfig?
    var eventListener: IQChannelsEventListenerProtocol?
    var unreadListeners: [IQChannelsUnreadListenerProtocol] = []
    var subscriptions = Set<AnyCancellable>()
    
    //MARK: - Managers
    /// Key is channel
    var networkManagers: [String: any IQNetworkManagerProtocol]
    let networkStatusManager = IQNetworkStatusManager()
    let storageManager = IQStorageManager()
    var currentNetworkManager: IQNetworkManagerProtocol? {
        guard let channel = selectedChat?.auth.channel else { return nil}
        return networkManagers[channel]
    }
    
    init(configuration: IQChannelsConfig) {
        self.config = configuration
        var networkManagers = [String: IQNetworkManagerProtocol]()
        configuration.channels.forEach {
            networkManagers.updateValue(IQNetworkManager(address: configuration.address, channel: $0), forKey: $0)
        }
        self.networkManagers = networkManagers
        
        networkStatusManager.delegate = self
        
        setupCombine()
        setupImageManager()
        setupFileLimits()
    }
    
    func configure(configuration: IQChannelsConfig) {
        logout()
        
        self.config = configuration
        var networkManagers = [String: IQNetworkManagerProtocol]()
        configuration.channels.forEach {
            networkManagers.updateValue(IQNetworkManager(address: configuration.address, channel: $0), forKey: $0)
        }
        self.networkManagers = networkManagers
        
        networkStatusManager.delegate = self
        
        configureCombine()
        setupImageManager()
        setupFileLimits()
    }
    
    func setCustomHeaders(_ headers: [String: String]) {
        headers.forEach { key, value in
            SDWebImageDownloader.shared.setValue(value, forHTTPHeaderField: key)
        }
        networkManagers.values.forEach { $0.setCustomHeaders(headers) }
    }
    
    func setListViewModel(_ viewModel: IQChatListViewModel?) {
        self.listViewModel = viewModel
        listViewModel?.chatsInfo = getChatItems(from: authResults)
    }
    
    func addEvent(listener: any IQChannelsEventListenerProtocol) {
        eventListener = listener
    }
    
    func removeEventListener() {
        eventListener = nil
    }
    
    func addUnread(listener: IQChannelsUnreadListenerProtocol) {
        unreadListeners.append(listener)
    }
    
    func removeUnread(listener: IQChannelsUnreadListenerProtocol) {
        unreadListeners.removeAll(where: { $0.id == listener.id })
    }
    
    func login(_ loginType: IQLoginType) {
        logout()
        auth(loginType)
    }
    
    func logout() {
        IQLog.debug(message: "logout")
        listViewModel?.dismissListener.send(())
        clear()
    }
    
}
