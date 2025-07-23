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
    
    var description: String {
        switch self {
        case .authenticated:
            return IQLanguageTexts.model.statusLabel ?? "На связи"
        case .awaitingNetwork:
            return IQLanguageTexts.model.statusLabelAwaitingNetwork ?? "Ожидание сети..."
        case .authenticating:
            return ""
        case .loggedOut:
            return ""
        }
    }
}
