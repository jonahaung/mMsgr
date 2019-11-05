//
//  Sequence.swift
//  mMsgr
//
//  Created by jonahaung on 21/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Foundation


extension Sequence {

    func asyncForEach(completion: @escaping () -> (), block: (Iterator.Element, @escaping () -> ()) -> ()) {
        let group = DispatchGroup()
        let innerCompletion = { group.leave() }
        for x in self {
            group.enter()
            block(x, innerCompletion)
        }
        group.notify(queue: DispatchQueue.main, execute: completion)
    }
    
    func all(_ condition: (Iterator.Element) -> Bool) -> Bool {
        for x in self where !condition(x) {
            return false
        }
        return true
    }
    
    func some(_ condition: (Iterator.Element) -> Bool) -> Bool {
        for x in self where condition(x) {
            return true
        }
        return false
    }
}


