//
//  NavAvatarImageView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 5/3/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class BadgeAvatarImageView: AvatarImageView {

    typealias Action = (BadgeAvatarImageView) -> Swift.Void
    private(set) var actionOnTouch: Action?
    
    private let badgeLabel = BadgeLabel()
    
    var badge: String? {
        didSet {
            guard oldValue != badge else { return }
            badgeLabel.label.text = badge
            setNeedsLayout()
        }
    }
    
    var badgeColor: UIColor? {
        didSet {
            guard badgeColor != oldValue else { return }
            badgeLabel.backgroundColor = badgeColor
            backColor = badgeColor
            setNeedsLayout()
        }
    }
    
    override func setup() {
        super.setup()
        padding = 2
        addSubview(badgeLabel)
        badge = "     "
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !badgeLabel.isHidden {
            badgeLabel.fontSize = (bounds.height / 6).rounded()
            badgeLabel.frame = badgeLabel.intrinsicContentSize.bma_rect(inContainer: bounds, xAlignament: .right, yAlignment: .bottom)
        }
    }
    
    func action(_ closure: @escaping Action) {
        actionOnTouch = closure
    }
    
    func badgeAction(_ closure: @escaping BadgeLabel.Action) {
        badgeLabel.action(closure)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            actionOnTouch?(self)
        }
    }
}
