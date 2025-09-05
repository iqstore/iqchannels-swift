//
//  IQLanguageTextsModel.swift
//  IQChannelsSwift
//
//  Created by Mikhail Zinkov on 25.06.2025.
//

import Foundation
import SwiftUI

struct IQLanguageTextsModel: Decodable {
    var code: String?
    var signupTitle: String?
    var signupSubtitle: String?
    var signupNamePlaceholder: String?
    var signupCheckboxText: String?
    var signupButtonText: String?
    var signupError: String?
    var titleError: String?
    var textError: String?
    var buttonError: String?
    var statusLabel: String?
    var statusLabelAwaitingNetwork: String?
    var operatorTyping: String?
    var inputMessagePlaceholder: String?
    var textFileStateRejected: String?
    var textFileStateOnChecking: String?
    var textFileStateSentForCheck: String?
    var textFileStateCheckError: String?
    var ratingStatePending: String?
    var ratingStateIgnored: String?
    var ratingStateRated: String?
    var newMessages: String?
    var sentRating: String?
    var invalidMesssage: String?
    var imageLoadError: String?
    var ratingOfferTitle: String?
    var ratingOfferYes: String?
    var ratingOfferNo: String?
    var senderNameAnonym: String?
    var senderNameSystem: String?
    var textCopied: String?
    var copy: String?
    var reply: String?
    var resend: String?
    var delete: String?
    var fileSavedTitle: String?
    var fileSavedText: String?
    var fileSavedError: String?
    var photoSavedSuccessTitle: String?
    var photoSavedErrorTitle: String?
    var photoSavedSuccessText: String?
    var photoSavedErrorText: String?
    var galleryPermissionDeniedTitle: String?
    var galleryPermissionDeniedText: String?
    var galleryPermissionAlertCancel: String?
    var galleryPermissionAlertSettings: String?
    var fileSizeError: String?
    var fileWeightError: String?
    var fileNotAllowed: String?
    var fileForbidden: String?
    var gallery: String?
    var file: String?
    var camera: String?
    var cancel: String?
    var today: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case signupTitle = "signup_title"
        case signupSubtitle = "signup_subtitle"
        case signupNamePlaceholder = "signup_name_placeholder"
        case signupCheckboxText = "signup_checkbox_text"
        case signupButtonText = "signup_button_text"
        case signupError = "signup_error"
        case titleError = "title_error"
        case textError = "text_error"
        case buttonError = "button_error"
        case statusLabel = "status_label"
        case statusLabelAwaitingNetwork = "status_label_awaiting_network"
        case operatorTyping = "operator_typing"
        case inputMessagePlaceholder = "input_message_placeholder"
        case textFileStateRejected = "text_file_state_rejected"
        case textFileStateOnChecking = "text_file_state_on_checking"
        case textFileStateSentForCheck = "text_file_state_sent_for_check"
        case textFileStateCheckError = "text_file_state_check_error"
        case ratingStatePending = "rating_state_pending"
        case ratingStateIgnored = "rating_state_ignored"
        case ratingStateRated = "rating_state_rated"
        case newMessages = "new_messages"
        case sentRating = "sent_rating"
        case invalidMesssage = "invalid_messsage"
        case imageLoadError = "image_load_error"
        case ratingOfferTitle = "rating_offer_title"
        case ratingOfferYes = "rating_offer_yes"
        case ratingOfferNo = "rating_offer_no"
        case senderNameAnonym = "sender_name_anonym"
        case senderNameSystem = "sender_name_system"
        case textCopied = "text_copied"
        case copy
        case reply
        case resend
        case delete
        case fileSavedTitle = "file_saved_title"
        case fileSavedText = "file_saved_text"
        case fileSavedError = "file_saved_error"
        case photoSavedSuccessTitle = "photo_saved_success_title"
        case photoSavedErrorTitle = "photo_saved_error_title"
        case photoSavedSuccessText = "photo_saved_success_text"
        case photoSavedErrorText = "photo_saved_error_text"
        case galleryPermissionDeniedTitle = "gallery_permission_denied_title"
        case galleryPermissionDeniedText = "gallery_permission_denied_text"
        case galleryPermissionAlertCancel = "gallery_permission_alert_cancel"
        case galleryPermissionAlertSettings = "gallery_permission_alert_settings"
        case fileSizeError = "file_size_error"
        case fileWeightError = "file_weight_error"
        case fileNotAllowed = "file_not_allowed"
        case fileForbidden = "file_forbidden"
        case gallery
        case file
        case camera
        case cancel
        case today
    }
}
