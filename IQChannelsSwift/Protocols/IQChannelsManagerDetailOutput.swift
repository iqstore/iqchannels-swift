//
//  IQChannelsManagerDetailOutput.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 09.05.2024.
//

import Foundation
import PhotosUI

protocol IQChannelsManagerDetailOutput {
    func detailControllerIsTyping()
    func detailControllerDismissChat()
    func detailControllerDidPop()
    func detailController(didCancelUpload message: IQMessage)
    func detailController(didCancelSend message: IQMessage)
    func detailController(didDisplayMessageWith id: Int)
    func detailController(didCopyMessage message: IQMessage)
    func detailController(didSelect choice: IQSingleChoice)
    func detailController(didSelect action: IQAction)
    func detailController(didRate value: Int, ratingID: Int)
    func detailController(didSendPoll value: Int?, answers: [IQRatingPollClientAnswerInput], ratingID: Int, pollId: Int)
    func detailController(didPollIgnored ratingID: Int, pollId: Int)
    func detailController(didSend text: String, files: [DataFile]?, replyToMessage: Int?)
    func detailController(didResend message: IQMessage)
    func detailController(didPick items: [(URL?, UIImage?)])
    func detailController(didPick results: [PHPickerResult])
}
