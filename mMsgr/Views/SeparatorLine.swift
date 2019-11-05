//
//  InputBar.swift
//  mMsgr
//
//  Created by jonahaung on 7/6/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//
import UIKit


 class SeparatorLine: CustomView {
    
    var separaterHeight: CGFloat = 0 {
        didSet {
//            constraints.filter { $0.identifier == "height" }.forEach { $0.constant = separaterHeight }
            if superview != nil {
                invalidateIntrinsicContentSize()
            }
            
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: separaterHeight)
    }
    
    override func setup() {
        super.setup()
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}


