//
//  Pronounce+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 14/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import CoreData

extension Pronounce {
    
    static func fetch(word: String) -> Pronounce? {
        return Pronounce.findOrFetch(in: PersistenceManager.sharedInstance.editorContext, predicate: NSPredicate(format: "word MATCHES[c] %@", word))
    }
    
}
