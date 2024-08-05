//
//  IQFileState.swift
//  Pods
//
//  Created by Muhammed Aralbek on 29.07.2024.
//  
//

import Foundation
import SwiftUI

enum IQFileState: String, Codable {
    case approved = "approved"
    case rejected = "rejected"
    case onChecking = "on_checking"
    case sentForCheck = "sent_for_checking"
    case checkError = "check_error"
    
    var title: String {
        switch self {
        case .approved: return ""
        case .rejected: return "Небезопасный файл"
        case .onChecking: return "Файл на проверке"
        case .sentForCheck: return "Файл отправлен на проверку"
        case .checkError: return "Ошибка проверки файла"
        }
    }
    
    var titleClientColor: Color {
        switch self {
        case .approved: return Color.white
        case .rejected: return Style.getColor(theme: Style.model?.messages?.textFileStateRejectedClient?.color) ?? Color.red
        case .onChecking: return Style.getColor(theme: Style.model?.messages?.textFileStateOnCheckingClient?.color) ?? Color.white
        case .sentForCheck: return Style.getColor(theme: Style.model?.messages?.textFileStateSentForCheckingClient?.color) ?? Color.white
        case .checkError: return Style.getColor(theme: Style.model?.messages?.textFileStateCheckErrorClient?.color) ?? Color.red
        }
    }
    
    var titleOperatorColor: Color {
        switch self {
        case .approved: return Color.white
        case .rejected: return Style.getColor(theme: Style.model?.messages?.textFileStateRejectedOperator?.color) ?? Color.red
        case .onChecking: return Style.getColor(theme: Style.model?.messages?.textFileStateOnCheckingOperator?.color) ?? Color.white
        case .sentForCheck: return Style.getColor(theme: Style.model?.messages?.textFileStateSentForCheckingOperator?.color) ?? Color.white
        case .checkError: return Style.getColor(theme: Style.model?.messages?.textFileStateCheckErrorOperator?.color) ?? Color.red
        }
    }
    
    var titleClientFontSize: CGFloat {
        switch self {
        case .approved: return 17
        case .rejected: return CGFloat(Style.model?.messages?.textFileStateRejectedClient?.textSize ?? 17)
        case .onChecking: return CGFloat(Style.model?.messages?.textFileStateOnCheckingClient?.textSize ?? 17)
        case .sentForCheck: return CGFloat(Style.model?.messages?.textFileStateSentForCheckingClient?.textSize ?? 17)
        case .checkError: return CGFloat(Style.model?.messages?.textFileStateCheckErrorClient?.textSize ?? 17)
        }
    }
    
    var titleOperatorFontSize: CGFloat {
        switch self {
        case .approved: return 17
        case .rejected: return CGFloat(Style.model?.messages?.textFileStateRejectedOperator?.textSize ?? 17)
        case .onChecking: return CGFloat(Style.model?.messages?.textFileStateOnCheckingOperator?.textSize ?? 17)
        case .sentForCheck: return CGFloat(Style.model?.messages?.textFileStateSentForCheckingOperator?.textSize ?? 17)
        case .checkError: return CGFloat(Style.model?.messages?.textFileStateCheckErrorOperator?.textSize ?? 17)
        }
    }
}
