//
//  IQBaseViewModel.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 18.05.2024.
//

import Combine

class IQBaseViewModel: ObservableObject {
//    @Published var state: IQChannelsState = .awaitingNetwork
    @Published var state: IQChannelsState = .authenticated
    var errorListener = PassthroughSubject<Error, Never>()
}

extension Sequence where Element == IQBaseViewModel {
    func setState(_ state: IQChannelsState) {
        forEach { $0.state = state }
    }
    
    func sendError(_ error: Error) {
        forEach { $0.errorListener.send(error) }
    }
}
