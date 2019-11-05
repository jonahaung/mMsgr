//
//  ChatHeaderView.swift
//  mMsgr
//
//  Created by jonahaung on 15/9/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

final class ChatHeaderView: ReusableSupplementryView {

    
    var text: String? {
        didSet {
            guard text != oldValue else { return }
            label.text = text

        }
    }
    
    private let label: UILabel = {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote)
        $0.adjustsFontForContentSizeCategory = true
        $0.textColor = UIColor.quaternaryLabel
        $0.isOpaque = true
        return $0
    }(UILabel())
    override func setup() {
        super.setup()

        addSubview(label)
        label.centerInSuperview()
    }

    func configure(msg: Message) {
        
        text = MessageDateFormatter.shared.string(from: msg.date)
    }
}
