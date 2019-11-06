//
//  SystemMsgCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 24/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class SystemMsgCell: CollectionViewCell {
    
    private let holderView: UIView = {
        $0.backgroundColor = UIColor.tertiarySystemFill
        return $0
    }(UIView())
    
    private let label: UILabel = {
        $0.textAlignment = .center
        $0.textColor = UIColor.random()
        $0.numberOfLines = 0
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return $0
    }(UILabel())
    override func setup() {
        super.setup()
        holderView.addSubview(label)
        contentView.addSubview(holderView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        holderView.frame = contentView.bounds.inset(by: UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20))
        label.frame = holderView.bounds
    }
    
    func configure(msg: Message) {
        label.text = msg.text
    }
}
