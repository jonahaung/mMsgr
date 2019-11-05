//
//  UITextView+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 3/3/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

extension UITextView {
    /// Moves the caret to the correct position by removing the trailing whitespace
    func ensureCaretToTheEnd() {
        // Moving the caret to the correct position by removing the trailing whitespace
        // http://stackoverflow.com/questions/14220187/uitextfield-has-trailing-whitespace-after-securetextentry-toggle
        let beginning = beginningOfDocument
        selectedTextRange = textRange(from: beginning, to: beginning)
        let end = endOfDocument
        selectedTextRange = textRange(from: end, to: end)
    }
}

extension Character {
    
    static let newLine: Character = "\n"
    
    static let tab: Character = "\t"
    
    static let terminator: Character = "\0"
}
