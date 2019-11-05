//
//  Spacer.swift
//  mMsgr
//
//  Created by Aung Ko Min on 4/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class MySpacer: CustomView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: verticalHeight)
    }
    var verticalHeight: CGFloat = 0.5
    
    override func setup() {
        super.setup()
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }
}
