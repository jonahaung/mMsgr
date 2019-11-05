//
//  LinkPresentation+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import LinkPresentation

extension LPLinkMetadata {
    
    func store(at docUrl: URL) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
            try data.write(to: docUrl, options: .atomic)
            
        } catch { print(error) }
    }
}
