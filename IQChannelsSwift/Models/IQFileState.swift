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
    
    var titleColor: Color {
        switch self {
        case .approved: return Color.white
        case .rejected: return Style.getColor(theme: Style.model?.messages?.textFileStateRejected?.color) ?? Color.white
        case .onChecking: return Style.getColor(theme: Style.model?.messages?.textFileStateOnChecking?.color) ?? Color.white
        case .sentForCheck: return Style.getColor(theme: Style.model?.messages?.textFileStateSentForChecking?.color) ?? Color.white
        case .checkError: return Style.getColor(theme: Style.model?.messages?.textFileStateCheckError?.color) ?? Color.white
        }
    }
    
    var titleFontSize: CGFloat {
        switch self {
        case .approved: return 17
        case .rejected: return CGFloat(Style.model?.messages?.textFileStateRejected?.textSize ?? 17)
        case .onChecking: return CGFloat(Style.model?.messages?.textFileStateOnChecking?.textSize ?? 17)
        case .sentForCheck: return CGFloat(Style.model?.messages?.textFileStateSentForChecking?.textSize ?? 17)
        case .checkError: return CGFloat(Style.model?.messages?.textFileStateCheckError?.textSize ?? 17)
        }
    }
}
