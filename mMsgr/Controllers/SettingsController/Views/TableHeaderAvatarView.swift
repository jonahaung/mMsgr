//
//  TableHeaderAvatarView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 17/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class TableHeaderAvatarView: CustomView {

    var avatarImageView: BadgeAvatarImageView = {
        $0.isUserInteractionEnabled = true
        $0.diameter = 200
        $0.backColor = UIColor.systemYellow
        $0.badgeColor = UIColor.link
        return $0
    }(BadgeAvatarImageView())

    override func setup() {
        super.setup()
        isUserInteractionEnabled = true
        addSubview(avatarImageView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.frame = avatarImageView.bounds.size.bma_rect(inContainer: bounds, xAlignament: .center, yAlignment: .center)
        avatarImageView.dropShadow()

    }
    
    func refreshImage(refresh: Bool) {
        avatarImageView.loadImageForCurrentUser(refresh: refresh)
    }
}
extension UIView {
    
    func roundedShadow() {
       
        let radius = bounds.height/2
        self.maskToBounds = false
        self.cornerRadius = radius
        self.shadowColor = UIColor.label
        self.shadowOffset = CGSize(width: 1, height: 5)
        self.shadowRadius = 8
        self.shadowOpacity = 0.2
        self.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        self.shadowShouldRasterize = true
        self.shadowRasterizationScale = UIMainScreenScale
    }
}
