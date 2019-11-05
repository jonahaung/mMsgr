//
//  Sequence+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 15/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation

extension Sequence {
    func group<GroupingType: Hashable>(by key: (Iterator.Element) -> GroupingType) -> [[Iterator.Element]] {
        var groups: [GroupingType: [Iterator.Element]] = [:]
        var groupsOrder: [GroupingType] = []
        forEach { element in
            let key = key(element)
            
            if case nil = groups[key]?.append(element) {
                groups[key] = [element]
                groupsOrder.append(key)
            }
        }
        return groupsOrder.map { groups[$0]! }
    }
}
