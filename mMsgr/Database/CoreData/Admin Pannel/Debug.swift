//
//  Debug.swift
//  mMsgr
//
//  Created by Aung Ko Min on 25/1/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

class Debug {
    
    class func debug() {
//        ChatAPI.sharedInstance.deleteAllData(entity: "Room")
//        ChatAPI.sharedInstance.deleteAllData(entity: "Friend")
//        ChatAPI.sharedInstance.loadWordsFiles(isZawGyi: false)
//        StartUp.loadMyanmarLanguageData()
        
    }
    
    
    func encrypt(message: String, shift: Int) -> String {
        
        func shiftLetter(ucs: UnicodeScalar) -> UnicodeScalar {
            let firstLetter = Int(UnicodeScalar("A").value)
            let lastLetter = Int(UnicodeScalar("Z").value)
            let letterCount = lastLetter - firstLetter + 1
            
            let value = Int(ucs.value)
            switch value {
            case firstLetter...lastLetter:
                // Offset relative to first letter:
                var offset = value - firstLetter
                // Apply shift amount (can be positive or negative):
                offset += shift
                // Transform back to the range firstLetter...lastLetter:
                offset = (offset % letterCount + letterCount) % letterCount
                // Return corresponding character:
                return UnicodeScalar(firstLetter + offset)!
            default:
                // Not in the range A...Z, leave unchanged:
                return ucs
            }
        }
        
        let msg = message.uppercased()
        return String(String.UnicodeScalarView(msg.unicodeScalars.map(shiftLetter)))
    }
    
}


