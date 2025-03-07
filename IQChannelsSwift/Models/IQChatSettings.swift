//
//  IQChatSettings.swift
//  Pods
//
//  Created by Mikhail Zinkov on 09.12.2024.
//

struct IQChatSettings: Codable, Equatable {
    var id: Int = 0
    var message: String = "Здравствуйте!"
    var enabled: Bool = true
    var greetFrom: String = "user"
    var lifetime: Int = 300
    var operatorName: String = "Оператор"
    var totalOpenedTickets: Int = 0
}
