//
//  Int64+Ext.swift
//  mMsgr
//
//  Created by jonahaung on 18/10/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Foundation


extension Int64 {
    
    func TimeElapsed() -> String {
    
        let date = Date.date(timestamp: self)
        return date.forChatMessage()
//        let seconds = Date().timeIntervalSince(date)
//
//        if (seconds < 60) {
//            elapsed = "Just now"
//        } else if (seconds < 60 * 60) {
//            let minutes = Int(seconds / 60)
//            elapsed = "\(minutes)m agoo"
//        } else if (seconds < 24 * 60 * 60) {
//            let hours = Int(seconds / (60 * 60))
//            elapsed = "\(hours)h ago"
//        } else if (seconds < 7 * 24 * 60 * 60) {
//            elapsed = date.forChatMessage()
//        } else {
//            elapsed = date.dateTimeString(ofStyle: .short)
//        }
//
//        return elapsed
    }

}
