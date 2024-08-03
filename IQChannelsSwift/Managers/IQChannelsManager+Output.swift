//
//  IQChannelsManager+Output.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 08.05.2024.
//

import Foundation
import PhotosUI

extension IQChannelsManager: IQChannelsManagerListOutput {
    func listControllerDismissChat() {
        guard eventListener?.iqChannelsShouldCloseModule() ?? true else { return }
        
        logout()
    }
    
    func listController(didSelectChat item: IQChatItemModel) {
        guard let authResult = authResults.first(where: { $0.channel == item.channel } ) else { return }
        
        selectedChat = (authResult, item.chatType)
    }
}

extension IQChannelsManager: IQChannelsManagerDetailOutput {
    
    func detailController(didSend text: String, replyToMessage: Int?) {
        sendText(text, replyToMessage: replyToMessage)
    }
    
    func detailController(didPick items: [(URL?, UIImage?)], replyToMessage: Int?) {
        sendFiles(items: items, replyToMessage: replyToMessage)
    }
    
    func detailControllerDismissChat() {
        guard eventListener?.iqChannelsShouldCloseModule() ?? true else { return }
        
        logout()
    }

    func detailControllerDidPop() {
        guard eventListener?.iqChannelsShouldCloseChat() ?? true else { return }
        
        closeCurrentChat()
    }
    
    func detailController(didPick results: [PHPickerResult], replyToMessage: Int?) {
        sendImages(result: results, replyToMessage: replyToMessage)
    }
    
    func detailController(didCancelUpload message: IQMessage) {
        cancelUploadFileMessage(message)
    }

    func detailController(didDisplayMessageWith id: Int) {
        messageDisplayed(id)
    }
    
    func detailController(didCopyMessage message: IQMessage) {
        UIPasteboard.general.string = message.text
    }
    
    func detailController(didSelect file: IQFile) {
        openFileInBrowser(file)
    }
    
    func detailController(didRate value: Int, ratingID: Int) {
        rate(value: value, ratingID: ratingID)
    }
    
    func detailController(didSelect choice: IQSingleChoice) {
        send(choice)
    }
    
    func detailController(didSelect action: IQAction) {
        send(action)
    }

    func detailControllerIsTyping() {
        sendTypingEvent()
    }
}
