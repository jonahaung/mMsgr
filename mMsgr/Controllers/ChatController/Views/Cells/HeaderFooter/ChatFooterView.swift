//
//  ChatFooterView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 29/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class ChatFooterView: ReusableSupplementryView {
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MsgCellLayoutAttributes else { return }
        label.sizeToFit()
        
        var labelCenter = CGPoint.zero
        labelCenter.x = attributes.isSender ? attributes.bounds.width - label.bounds.width : label.bounds.width
        labelCenter.y = bounds.midY
        label.center = labelCenter
    }
    
    private let label: UILabel = {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote)
        $0.textColor = UIColor.tertiaryLabel
        return $0
    }(UILabel())
    
    override func setup() {
        super.setup()
        addSubview(label)
        
    }
}

