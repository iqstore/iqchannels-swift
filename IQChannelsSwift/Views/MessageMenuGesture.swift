//
//  MessageMenuGesture.swift
//  IQChannelsSwift
//
//  Created by Mikhail Zinkov on 20.11.2026.
//

import SwiftUI

struct MessageMenuGesture: ViewModifier {

    let message: IQMessage
    let replyMessage: IQMessage?
    let onLongPress: ((MessageControlInfo) -> Void)?

    @State private var keyboardShown = false
    @State private var computeFrame = false
    @State private var frame: CGRect = .zero

    func body(content: Content) -> some View {
        content
            .onReceive(EmptyView().keyboardPublisher) { keyboardShown = $0 }
            .background(
                GeometryReader { proxy in
                    Rectangle().fill(SwiftUI.Color.clear)
                        .onChange(of: computeFrame) { _ in
                            DispatchQueue.main.async {
                                frame = proxy.frame(in: .global)
                            }
                        }
                }
            )
            .onLongPressGesture {
                if keyboardShown {
                    resignFirstResponder()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        computeFrameOnPress()
                    }
                } else {
                    computeFrameOnPress()
                }
            }
    }

    private func computeFrameOnPress() {
        computeFrame = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            computeFrame = false
            EmptyView().triggerHapticFeedback(style: .medium)
            onLongPress?(MessageControlInfo(message: message, replyMessage: replyMessage, frame: frame))
        }
    }
}
