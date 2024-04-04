import Foundation

enum IQChatPayloadType: String {
    case invalid = ""
    case text
    case file
    case rating
    case notice
    case singleChoice = "single-choice"
    case card
    case carousel
}
