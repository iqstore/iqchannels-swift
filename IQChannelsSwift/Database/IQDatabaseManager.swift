//
//  IQDatabaseManager.swift
//  Pods
//
//  Created by Mikhail Zinkov on 27.12.2024.
//

import SQLite

class IQDatabaseManager {
    static let shared = IQDatabaseManager()
    private var db: Connection!
    
    typealias Expression = SQLite.Expression

    // Таблица и поля
    private let messages = Table("messages")
    private let uid = Expression<Int>("uid")
    private let messageID = Expression<Int>("messageId")
    private let localID = Expression<Int?>("localId")
    private let fileID = Expression<String?>("fileId")
    private let chatID = Expression<Int?>("chatId")
    private let createdAt = Expression<Int?>("createdAt")
    private let userID = Expression<Int?>("userId")
    private let clientID = Expression<Int?>("clientId")
    private let ratingID = Expression<Int?>("ratingId")
    private let payload = Expression<String?>("payload")
    private let text = Expression<String?>("text")
    private let author = Expression<String?>("author")
    private let isRead = Expression<Bool?>("isRead")
    private let replyToMessageID = Expression<Int?>("replyToMessageId")
    private let botpressPayload = Expression<String?>("botpressPayload")
    private let isDropDown = Expression<Bool?>("isDropDown")
    private let disableFreeText = Expression<Bool?>("disableFreeText")
    private let isSystem = Expression<Bool?>("isSystem")
    private let actions = Expression<String?>("actions")
    private let singleChoices = Expression<String?>("singleChoices")
    private let chatType = Expression<String?>("chatType")
    private let eventID = Expression<Int?>("eventId")
    private let client = Expression<String?>("client")
    private let user = Expression<String?>("user")
    private let file = Expression<String?>("file")
    private let rating = Expression<String?>("rating")
    private let upload = Expression<String?>("upload")
    private let error = Expression<Bool>("error")

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/iq_database.sqlite3")

            try db.run(messages.create(ifNotExists: true) { t in
                t.column(uid, primaryKey: .autoincrement)
                t.column(messageID)
                t.column(localID, unique: true)
                t.column(fileID)
                t.column(chatID)
                t.column(createdAt)
                t.column(userID)
                t.column(clientID)
                t.column(ratingID)
                t.column(payload)
                t.column(text)
                t.column(author)
                t.column(isRead)
                t.column(replyToMessageID)
                t.column(botpressPayload)
                t.column(isDropDown)
                t.column(disableFreeText)
                t.column(isSystem)
                t.column(actions)
                t.column(singleChoices)
                t.column(chatType)
                t.column(eventID)
                t.column(client)
                t.column(user)
                t.column(file)
                t.column(rating)
                t.column(upload)
                t.column(error)
            })
            
            checkColumns()
        } catch {
            print("Error initializing database: \(error)")
        }
    }
    
    // Проверка колон в базе
    func checkColumns() {
        do {
            // Проверка существования колонки "error"
            let checkColumnExists = try db.scalar("""
               SELECT COUNT(*)
               FROM pragma_table_info('messages')
               WHERE name = 'error'
            """) as! Int64

            if checkColumnExists == 0 {
                // Если колонка "error" не существует, добавляем её
                do {
                    try db.run(messages.addColumn(error, defaultValue: false))
                } catch {
                    print("Error add columns: \(error)")
                }
            }
        } catch {
            print("Error check columns: \(error)")
        }
    }
    
    // Вставка или обновление сообщения
    func insertMessage(_ message: IQDatabaseMessage) {
        if(message.localID != 0){
            do {
                try db.run(messages.insert(or: .replace,
                   messageID <- message.messageID,
                   localID <- message.localID,
                   fileID <- message.fileID,
                   chatID <- message.chatID,
                   createdAt <- message.createdAt,
                   userID <- message.userID,
                   clientID <- message.clientID,
                   ratingID <- message.ratingID,
                   payload <- message.payload,
                   text <- message.text,
                   author <- message.author,
                   isRead <- message.isRead,
                   replyToMessageID <- message.replyToMessageID,
                   botpressPayload <- message.botpressPayload,
                   isDropDown <- message.isDropDown,
                   disableFreeText <- message.disableFreeText,
                   isSystem <- message.isSystem,
                   actions <- message.actions,
                   singleChoices <- message.singleChoices,
                   chatType <- message.chatType,
                   eventID <- message.eventID,
                   client <- message.client,
                   user <- message.user,
                   file <- message.file,
                   rating <- message.rating,
                   upload <- message.upload,
                   error <- message.error
                  ))
            } catch {
                print("Error inserting message: \(error)")
            }
        }
    }

    // Получение всех сообщений
    func getAllMessages() -> [IQDatabaseMessage] {
        var messagesArray: [IQDatabaseMessage] = []
        do {
            for message in try db.prepare(messages) {
                messagesArray.append(IQDatabaseMessage(
                    uid: message[uid],
                    messageID: message[messageID],
                    localID: message[localID],
                    fileID: message[fileID],
                    chatID: message[chatID],
                    createdAt: message[createdAt],
                    userID: message[userID],
                    clientID: message[clientID],
                    ratingID: message[ratingID],
                    payload: message[payload],
                    text: message[text],
                    author: message[author],
                    isRead: message[isRead],
                    replyToMessageID: message[replyToMessageID],
                    botpressPayload: message[botpressPayload],
                    isDropDown: message[isDropDown],
                    disableFreeText: message[disableFreeText],
                    isSystem: message[isSystem],
                    actions: message[actions],
                    singleChoices: message[singleChoices],
                    chatType: message[chatType],
                    eventID: message[eventID],
                    client: message[client],
                    user: message[user],
                    file: message[file],
                    rating: message[rating],
                    upload: message[upload],
                    error: message[error]
                ))
            }
        } catch {
            print("Error retrieving all messages: \(error)")
        }
        return messagesArray
    }

    // Удаление сообщения по localId
    func deleteMessageByLocalId(_ localIdValue: Int) -> Bool {
        do {
            let query = messages.filter(localID == localIdValue)
            if try db.run(query.delete()) > 0 {
                return true
            }
        } catch {
            print("Error deleting message by localId: \(error)")
        }
        return false
    }

    // Удаление сообщений по chatId
    func deleteMessageByChatId(_ chatIdValue: Int?) -> Bool {
        do {
            let query = messages.filter(chatID == chatIdValue)
            if try db.run(query.delete()) > 0 {
                return true
            }
        } catch {
            print("Error deleting messages by chatId: \(error)")
        }
        return false
    }
    
    // Прочитывание сообщений по chatId
    func readMessageByChatId(_ chatIdValue: Int?) {
        do {
            let query = messages.filter(chatID == chatIdValue)
            try db.run(messages.filter(chatID == chatIdValue).update(isRead <- true))
        } catch {
            print("Error reading messages by chatId: \(error)")
        }
    }
}
