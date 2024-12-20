//
//  IQRelations.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 10.05.2024.
//

import Foundation

struct IQRelations: Decodable {
    var channels: [IQChannel]? = nil
    var chats: [IQChat]? = nil
    var chatMessages: [IQMessage]? = nil
    var clients: [IQClient]? = nil
    var files: [IQFile]? = nil
    var ratings: [IQRating]? = nil
    var ratingPolls: [IQRatingPoll]? = nil
    var users: [IQUser]? = nil
}
