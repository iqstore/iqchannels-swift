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
    
    func detailController(didSend text: String, files: [DataFile]?, replyToMessage: Int?) {
        sendMessage(text, files: files, replyToMessage: replyToMessage)
    }
    
    func detailController(didPick items: [(URL?, UIImage?)]) {
        sendFiles(items: items)
    }
    
    func detailControllerDismissChat() {
        guard eventListener?.iqChannelsShouldCloseModule() ?? true else { return }
        
        logout()
    }

    func detailControllerDidPop() {
        guard eventListener?.iqChannelsShouldCloseChat() ?? true else { return }
        IQLog.debug(message: "detailControllerDidPop")
        closeCurrentChat()
    }
    
    func detailController(didPick results: [PHPickerResult]) {
        sendImages(result: results)
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
    
    func detailController(didSendPoll value: Int?, answers: [IQRatingPollClientAnswerInput], ratingID: Int, pollId: Int) {
        sendPoll(value: value, answers: answers, ratingID: ratingID, pollId: pollId)
    }
    
    func detailController(didPollIgnored ratingID: Int, pollId: Int) {
        pollIgnored(ratingID: ratingID, pollId: pollId)
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
