//
//  IQNetworkManagerProtocol.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 27.05.2024.
//

import Foundation

protocol IQNetworkManagerProtocol {
    var token: String? { get set }

    func setCustomHeaders(_ headers: [String: String])
    func cancelTask(with taskIdentifier: Int)
    func listenToEvents(request: IQListenEventsRequest, callback: @escaping ResponseCallbackClosure<[IQChatEvent]>)
    func listenToUnread(callback: @escaping ResponseCallbackClosure<Int>)
    func stopListenToEvents()
    func stopUnreadListeners()
    func pushToken(token: String) async -> Error?
    func sendReceivedEvent(_ messageIDs: [Int]) async -> Error?
    func sendReadEvent(_ messageIDs: [Int]) async -> Error?
    func sendTypingEvent() async -> Error?
    func loadMessages(request: IQLoadMessageRequest) async -> ResponseCallback<[IQMessage]>
    func rate(value: Int, ratingID: Int) async -> Error?
    func uploadFile(file: DataFile, taskIdentifierCallback: TaskIdentifierCallback?) async -> ResponseCallback<IQFile>
    func sendMessage(form: IQMessageForm) async -> Error?
    func clientsAuth(token: String) async -> ResponseCallback<IQClientAuth>
    func clientsSignup() async -> ResponseCallback<IQClientAuth>
    func clientsIntegrationAuth(credentials: String) async -> ResponseCallback<IQClientAuth>
}
