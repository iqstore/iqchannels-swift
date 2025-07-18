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
        case .rejected: return IQLanguageTexts.model.textFileStateRejected ?? "Небезопасный файл"
        case .onChecking: return IQLanguageTexts.model.textFileStateOnChecking ?? "Файл на проверке"
        case .sentForCheck: return IQLanguageTexts.model.textFileStateSentForCheck ?? "Файл отправлен на проверку"
        case .checkError: return IQLanguageTexts.model.textFileStateCheckError ?? "Ошибка проверки файла"
        }
    }
    
    var titleClientColor: Color {
        switch self {
        case .approved: return Color.white
        case .rejected: return IQStyle.getColor(theme: IQStyle.model?.messages?.textFileStateRejectedClient?.color) ?? Color.red
        case .onChecking: return IQStyle.getColor(theme: IQStyle.model?.messages?.textFileStateOnCheckingClient?.color) ?? Color.white
        case .sentForCheck: return IQStyle.getColor(theme: IQStyle.model?.messages?.textFileStateSentForCheckingClient?.color) ?? Color.white
        case .checkError: return IQStyle.getColor(theme: IQStyle.model?.messages?.textFileStateCheckErrorClient?.color) ?? Color.red
        }
    }
    var titleClientFontSize: CGFloat {
        switch self {
        case .approved: return 17
        case .rejected: return CGFloat(IQStyle.model?.messages?.textFileStateRejectedClient?.textSize ?? 17)
        case .onChecking: return CGFloat(IQStyle.model?.messages?.textFileStateOnCheckingClient?.textSize ?? 17)
        case .sentForCheck: return CGFloat(IQStyle.model?.messages?.textFileStateSentForCheckingClient?.textSize ?? 17)
        case .checkError: return CGFloat(IQStyle.model?.messages?.textFileStateCheckErrorClient?.textSize ?? 17)
        }
    }
    var titleClientIsBold: Bool {
        switch self {
        case .approved: return false
        case .rejected: return IQStyle.model?.messages?.textFileStateRejectedClient?.textStyle?.bold ?? false
        case .onChecking: return IQStyle.model?.messages?.textFileStateOnCheckingClient?.textStyle?.bold ?? false
        case .sentForCheck: return IQStyle.model?.messages?.textFileStateSentForCheckingClient?.textStyle?.bold ?? false
        case .checkError: return IQStyle.model?.messages?.textFileStateCheckErrorClient?.textStyle?.bold ?? false
        }
    }
    var titleClientIsItalic: Bool {
        switch self {
        case .approved: return false
        case .rejected: return IQStyle.model?.messages?.textFileStateRejectedClient?.textStyle?.italic ?? false
        case .onChecking: return IQStyle.model?.messages?.textFileStateOnCheckingClient?.textStyle?.italic ?? false
        case .sentForCheck: return IQStyle.model?.messages?.textFileStateSentForCheckingClient?.textStyle?.italic ?? false
        case .checkError: return IQStyle.model?.messages?.textFileStateCheckErrorClient?.textStyle?.italic ?? false
        }
    }
    var titleClientAligment: TextAlignment {
        switch self {
        case .approved: return .leading
        case .rejected: return stringToAlignment(stringAlignment: IQStyle.model?.messages?.textFileStateRejectedClient?.textAlign) ?? .leading
        case .onChecking: return stringToAlignment(stringAlignment: IQStyle.model?.messages?.textFileStateOnCheckingClient?.textAlign) ?? .leading
        case .sentForCheck: return stringToAlignment(stringAlignment: IQStyle.model?.messages?.textFileStateSentForCheckingClient?.textAlign) ?? .leading
        case .checkError: return stringToAlignment(stringAlignment: IQStyle.model?.messages?.textFileStateCheckErrorClient?.textAlign) ?? .leading
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    var titleOperatorFontSize: CGFloat {
        switch self {
        case .approved: return 17
        case .rejected: return CGFloat(IQStyle.model?.messages?.textFileStateRejectedOperator?.textSize ?? 17)
        case .onChecking: return CGFloat(IQStyle.model?.messages?.textFileStateOnCheckingOperator?.textSize ?? 17)
        case .sentForCheck: return CGFloat(IQStyle.model?.messages?.textFileStateSentForCheckingOperator?.textSize ?? 17)
        case .checkError: return CGFloat(IQStyle.model?.messages?.textFileStateCheckErrorOperator?.textSize ?? 17)
        }
    }
    var titleOperatorColor: Color {
        switch self {
        case .approved: return Color.white
        case .rejected: return IQStyle.getColor(theme: IQStyle.model?.messages?.textFileStateRejectedOperator?.color) ?? Color.red
        case .onChecking: return IQStyle.getColor(theme: IQStyle.model?.messages?.textFileStateOnCheckingOperator?.color) ?? Color.black
        case .sentForCheck: return IQStyle.getColor(theme: IQStyle.model?.messages?.textFileStateSentForCheckingOperator?.color) ?? Color.black
        case .checkError: return IQStyle.getColor(theme: IQStyle.model?.messages?.textFileStateCheckErrorOperator?.color) ?? Color.red
        }
    }
    var titleOperatorIsBold: Bool {
        switch self {
        case .approved: return false
        case .rejected: return IQStyle.model?.messages?.textFileStateRejectedOperator?.textStyle?.bold ?? false
        case .onChecking: return IQStyle.model?.messages?.textFileStateOnCheckingOperator?.textStyle?.bold ?? false
        case .sentForCheck: return IQStyle.model?.messages?.textFileStateSentForCheckingOperator?.textStyle?.bold ?? false
        case .checkError: return IQStyle.model?.messages?.textFileStateCheckErrorOperator?.textStyle?.bold ?? false
        }
    }
    var titleOperatorIsItalic: Bool {
        switch self {
        case .approved: return false
        case .rejected: return IQStyle.model?.messages?.textFileStateRejectedOperator?.textStyle?.italic ?? false
        case .onChecking: return IQStyle.model?.messages?.textFileStateOnCheckingOperator?.textStyle?.italic ?? false
        case .sentForCheck: return IQStyle.model?.messages?.textFileStateSentForCheckingOperator?.textStyle?.italic ?? false
        case .checkError: return IQStyle.model?.messages?.textFileStateCheckErrorOperator?.textStyle?.italic ?? false
        }
    }
    var titleOperatorAligment: TextAlignment {
        switch self {
        case .approved: return .leading
        case .rejected: return stringToAlignment(stringAlignment: IQStyle.model?.messages?.textFileStateRejectedOperator?.textAlign) ?? .leading
        case .onChecking: return stringToAlignment(stringAlignment: IQStyle.model?.messages?.textFileStateOnCheckingOperator?.textAlign) ?? .leading
        case .sentForCheck: return stringToAlignment(stringAlignment: IQStyle.model?.messages?.textFileStateSentForCheckingOperator?.textAlign) ?? .leading
        case .checkError: return stringToAlignment(stringAlignment: IQStyle.model?.messages?.textFileStateCheckErrorOperator?.textAlign) ?? .leading
        }
    }
}
