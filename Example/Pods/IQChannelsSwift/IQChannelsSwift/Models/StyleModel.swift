//
//  StyleModel.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 29.05.2024.
//

import Foundation

struct StyleModel: Decodable {
    let chat: Chat
    let messages: Messages
    let answer: Answer
    let messagesFile: MessagesFile
    let messagesImage: MessagesImage
    let singleChoice: SingleChoice
    let rating: Rating
    let typing: Typing
    let toolsToMessage: ToolsToMessage
    let theme: Apperance
    let error: ErrorStyle
    
    enum CodingKeys: String, CodingKey {
        case chat
        case messages
        case answer
        case messagesFile = "messages_file"
        case messagesImage = "messages_image"
        case singleChoice = "single-choice"
        case rating
        case typing = "tiping"
        case toolsToMessage = "tools_to_message"
        case theme = "theme"
        case error
    }
}

extension StyleModel {
    
    enum Apperance: String, Decodable {
        case light, dark, system
    }

    struct Chat: Decodable {
        let background: Theme
        let dateText: TextStyle
        let chatHistory: String
        let iconOperator: URL
        let systemText: TextStyle

        enum CodingKeys: String, CodingKey {
            case background
            case dateText = "date_text"
            case chatHistory = "chat_history"
            case iconOperator = "icon_operator"
            case systemText = "system_text"
        }
    }

    struct Messages: Decodable {
        let backgroundOperator: Theme
        let backgroundClient: Theme
        let textOperator: TextStyle
        let textClient: TextStyle
        let textTime: TextStyle
        let textUp: TextStyle

        enum CodingKeys: String, CodingKey {
            case backgroundOperator = "background_operator"
            case backgroundClient = "background_client"
            case textOperator = "text_operator"
            case textClient = "text_client"
            case textTime = "text_time"
            case textUp = "text_up"
        }
    }

    struct Answer: Decodable {
        let textUpMessage: TextStyle
        let backgroundTextUpMessage: Theme
        let textAnswer: TextStyle
        let iconCancel: URL
        let rightLine: ColorTheme

        enum CodingKeys: String, CodingKey {
            case textUpMessage = "text_up_message"
            case backgroundTextUpMessage = "background_text_up_message"
            case textAnswer = "text_answer"
            case iconCancel = "icon_cancel"
            case rightLine = "right_line"
        }
    }

    struct MessagesFile: Decodable {
        let backgroundOperator: Theme
        let backgroundClient: Theme
        let text: TextStyle
        let iconFile: URL
        let textTime: TextStyle
        let textUp: TextStyle

        enum CodingKeys: String, CodingKey {
            case backgroundOperator = "background_operator"
            case backgroundClient = "background_client"
            case text
            case iconFile = "icon_file"
            case textTime = "text_time"
            case textUp = "text_up"
        }
    }

    struct MessagesImage: Decodable {
        let backgroundOperator: Theme
        let backgroundClient: Theme
        let text: TextStyle
        let iconLoad: ColorTheme
        let textTime: TextStyle
        let textUp: TextStyle

        enum CodingKeys: String, CodingKey {
            case backgroundOperator = "background_operator"
            case backgroundClient = "background_client"
            case text
            case iconLoad = "icon_load"
            case textTime = "text_time"
            case textUp = "text_up"
        }
    }

    struct SingleChoice: Decodable {
        let backgroundButton: Theme
        let borderButton: BorderStyle
        let textButton: TextStyle
        let backgroundIVR: Theme
        let borderIVR: BorderStyle
        let textIVR: TextStyle

        enum CodingKeys: String, CodingKey {
            case backgroundButton = "background_button"
            case borderButton = "border_button"
            case textButton = "text_button"
            case backgroundIVR = "background_IVR"
            case borderIVR = "border_IVR"
            case textIVR = "text_IVR"
        }
    }

    struct Rating: Decodable {
        let backgroundContainer: Theme
        let text: TextStyle
        let textRating: TextStyle
        let textTime: TextStyle
        let fullStar: URL
        let emptyStar: URL
        let sentRating: SentRating

        enum CodingKeys: String, CodingKey {
            case backgroundContainer = "background_container"
            case text
            case textRating = "text_rating"
            case textTime = "text_time"
            case fullStar = "full_star"
            case emptyStar = "empty_star"
            case sentRating = "sent_rating"
        }

        struct SentRating: Decodable {
            let color: Theme
            let borders: Int
            let bordersColor: Theme
            let borderRadius: Int

            enum CodingKeys: String, CodingKey {
                case color
                case borders
                case bordersColor = "borders_color"
                case borderRadius = "border-radius"
            }
        }
    }

    struct Typing: Decodable {
        let background: Theme
        let text: TextStyle
    }

    struct ToolsToMessage: Decodable {
        let iconSent: URL
        let backgroundIcon: Theme
        let backgroundChat: Theme
        let borderChat: BorderStyle
        let textChat: TextStyle
        let iconClip: URL

        enum CodingKeys: String, CodingKey {
            case iconSent = "icon_sent"
            case backgroundIcon = "background_icon"
            case backgroundChat = "background_chat"
            case borderChat = "border_chat"
            case textChat = "text_chat"
            case iconClip = "icon_clip"
        }
    }

    struct ErrorStyle: Decodable {
        let titleError: TextStyle
        let textError: TextStyle
        let iconError: URL

        enum CodingKeys: String, CodingKey {
            case titleError = "title_error"
            case textError = "text_error"
            case iconError = "icon_error"
        }
    }

}

extension StyleModel {
    struct ColorTheme: Decodable {
        let color: Theme
    }

    struct Theme: Decodable {
        let light: String
        let dark: String
    }

    struct TextStyle: Decodable {
        let color: Theme
        let textSize: Int

        enum CodingKeys: String, CodingKey {
            case color
            case textSize = "text_size"
        }
    }

    struct BorderStyle: Decodable {
        let size: Int
        let color: Theme
        let borderRadius: Int

        enum CodingKeys: String, CodingKey {
            case size
            case color
            case borderRadius = "border-radius"
        }
    }
}
