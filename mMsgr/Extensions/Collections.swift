//
//  Collections.swift
//  mMsgr
//
//  Created by jonahaung on 5/10/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Foundation

extension BidirectionalCollection where Iterator.Element: Equatable {
    
    typealias Element = Self.Iterator.Element
    
    func after(_ item: Element, loop: Bool = false) -> Element? {
        if let itemIndex = self.firstIndex(of: item) {
            let lastItem: Bool = (index(after:itemIndex) == endIndex)
            if loop && lastItem {
                return self.first
            } else if lastItem {
                return nil
            } else {
                return self[index(after:itemIndex)]
            }
        }
        return nil
    }
    
    func before(_ item: Element) -> Element? {
        if let itemIndex = self.firstIndex(of: item) {
            guard itemIndex != startIndex else { return nil }
            return self[index(before: itemIndex)]
        }
        return nil
    }
}

extension Array {

    var middle: Element? {
        guard count != 0 else { return nil }

        let middleIndex = (count > 1 ? count - 1 : count) / 2
        return self[middleIndex]
    }

}
