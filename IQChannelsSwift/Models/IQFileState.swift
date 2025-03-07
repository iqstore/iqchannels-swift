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
    var titleClientFontSize: CGFloat {
        switch self {
        case .approved: return 17
        case .rejected: return CGFloat(Style.model?.messages?.textFileStateRejectedClient?.textSize ?? 17)
        case .onChecking: return CGFloat(Style.model?.messages?.textFileStateOnCheckingClient?.textSize ?? 17)
        case .sentForCheck: return CGFloat(Style.model?.messages?.textFileStateSentForCheckingClient?.textSize ?? 17)
        case .checkError: return CGFloat(Style.model?.messages?.textFileStateCheckErrorClient?.textSize ?? 17)
        }
    }
    var titleClientIsBold: Bool {
        switch self {
        case .approved: return false
        case .rejected: return Style.model?.messages?.textFileStateRejectedClient?.textStyle?.bold ?? false
        case .onChecking: return Style.model?.messages?.textFileStateOnCheckingClient?.textStyle?.bold ?? false
        case .sentForCheck: return Style.model?.messages?.textFileStateSentForCheckingClient?.textStyle?.bold ?? false
        case .checkError: return Style.model?.messages?.textFileStateCheckErrorClient?.textStyle?.bold ?? false
        }
    }
    var titleClientIsItalic: Bool {
        switch self {
        case .approved: return false
        case .rejected: return Style.model?.messages?.textFileStateRejectedClient?.textStyle?.italic ?? false
        case .onChecking: return Style.model?.messages?.textFileStateOnCheckingClient?.textStyle?.italic ?? false
        case .sentForCheck: return Style.model?.messages?.textFileStateSentForCheckingClient?.textStyle?.italic ?? false
        case .checkError: return Style.model?.messages?.textFileStateCheckErrorClient?.textStyle?.italic ?? false
        }
    }
    var titleClientAligment: TextAlignment {
        switch self {
        case .approved: return .leading
        case .rejected: return stringToAlignment(stringAlignment: Style.model?.messages?.textFileStateRejectedClient?.textAlign) ?? .leading
        case .onChecking: return stringToAlignment(stringAlignment: Style.model?.messages?.textFileStateOnCheckingClient?.textAlign) ?? .leading
        case .sentForCheck: return stringToAlignment(stringAlignment: Style.model?.messages?.textFileStateSentForCheckingClient?.textAlign) ?? .leading
        case .checkError: return stringToAlignment(stringAlignment: Style.model?.messages?.textFileStateCheckErrorClient?.textAlign) ?? .leading
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
    var titleOperatorColor: Color {
        switch self {
        case .approved: return Color.white
        case .rejected: return Style.getColor(theme: Style.model?.messages?.textFileStateRejectedOperator?.color) ?? Color.red
        case .onChecking: return Style.getColor(theme: Style.model?.messages?.textFileStateOnCheckingOperator?.color) ?? Color.black
        case .sentForCheck: return Style.getColor(theme: Style.model?.messages?.textFileStateSentForCheckingOperator?.color) ?? Color.black
        case .checkError: return Style.getColor(theme: Style.model?.messages?.textFileStateCheckErrorOperator?.color) ?? Color.red
        }
    }
    var titleOperatorIsBold: Bool {
        switch self {
        case .approved: return false
        case .rejected: return Style.model?.messages?.textFileStateRejectedOperator?.textStyle?.bold ?? false
        case .onChecking: return Style.model?.messages?.textFileStateOnCheckingOperator?.textStyle?.bold ?? false
        case .sentForCheck: return Style.model?.messages?.textFileStateSentForCheckingOperator?.textStyle?.bold ?? false
        case .checkError: return Style.model?.messages?.textFileStateCheckErrorOperator?.textStyle?.bold ?? false
        }
    }
    var titleOperatorIsItalic: Bool {
        switch self {
        case .approved: return false
        case .rejected: return Style.model?.messages?.textFileStateRejectedOperator?.textStyle?.italic ?? false
        case .onChecking: return Style.model?.messages?.textFileStateOnCheckingOperator?.textStyle?.italic ?? false
        case .sentForCheck: return Style.model?.messages?.textFileStateSentForCheckingOperator?.textStyle?.italic ?? false
        case .checkError: return Style.model?.messages?.textFileStateCheckErrorOperator?.textStyle?.italic ?? false
        }
    }
    var titleOperatorAligment: TextAlignment {
        switch self {
        case .approved: return .leading
        case .rejected: return stringToAlignment(stringAlignment: Style.model?.messages?.textFileStateRejectedOperator?.textAlign) ?? .leading
        case .onChecking: return stringToAlignment(stringAlignment: Style.model?.messages?.textFileStateOnCheckingOperator?.textAlign) ?? .leading
        case .sentForCheck: return stringToAlignment(stringAlignment: Style.model?.messages?.textFileStateSentForCheckingOperator?.textAlign) ?? .leading
        case .checkError: return stringToAlignment(stringAlignment: Style.model?.messages?.textFileStateCheckErrorOperator?.textAlign) ?? .leading
        }
    }
}
