//
//  General Extensions.swift
//  IQChannelsSwift
//
//  Created by Muhammed Aralbek on 16.05.2024.
//

import Foundation

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}

extension Array {
    @discardableResult
    mutating func remove(elementsAtIndices indicesToRemove: [Int]) -> [Element] {
        var shouldRemove: [Bool] = .init(repeating: false, count: count)
        
        for ix in indicesToRemove {
            shouldRemove[ix] = true
        }
        
        // Copy the removed elements in the specified order.
        let removedElements = indicesToRemove.map { self[$0] }
        
        // Compact the array
        var j = 0
        for i in 0..<count {
            if !shouldRemove[i] {
                self[j] = self[i]
                j+=1
            }
        }
        
        // Remove the extra elements from the end of the array.
        self.removeLast(count-j)
        
        return removedElements
    }
    
    subscript (safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
    
}
