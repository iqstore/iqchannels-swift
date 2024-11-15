//
//  SystemMessageCellView.swift
//  Pods
//
//  Created by  Mikhail Zinkov on 11.11.2024.
//

import SwiftUI

struct SystemMessageCellView: View {
    
    // MARK: - PROPERTIES
    private let message: IQMessage
    
    // MARK: - INIT
    init(message: IQMessage) {
        self.message = message
    }
    
    // MARK: - BODY
    var body: some View {
        TextSystemMessageCellView(message: message)
    }
}
