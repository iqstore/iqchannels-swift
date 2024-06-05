//
//  IQChannelState.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 14.05.2024.
//

import Foundation

enum IQChannelsState {
    case loggedOut
    case awaitingNetwork
    case authenticating
    case authenticated
    
    var description: String? {
        switch self {
        case .loggedOut, .authenticated:
            return nil
        case .awaitingNetwork:
            return "Ожидание сети..."
        case .authenticating:
            return "Авторизация..."
        }
    }
}
