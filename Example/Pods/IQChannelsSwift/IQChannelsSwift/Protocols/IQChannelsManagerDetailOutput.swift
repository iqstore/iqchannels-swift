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
    func detailControllerDidPop()
    func detailController(didCancelUpload message: IQMessage)
    func detailController(didDisplayMessageWith id: Int)
    func detailController(didCopyMessage message: IQMessage)
    func detailController(didSelect choice: IQSingleChoice)
    func detailController(didSelect action: IQAction)
    func detailController(didRate value: Int, ratingID: Int)
    func detailController(didSend text: String, replyToMessage: Int?)
    func detailController(didPick items: [(URL?, UIImage?)], replyToMessage: Int?)
    func detailController(didPick results: [PHPickerResult], replyToMessage: Int?)
}
