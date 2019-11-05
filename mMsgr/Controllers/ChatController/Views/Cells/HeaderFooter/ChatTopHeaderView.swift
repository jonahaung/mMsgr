//
//  ChatTopHeaderView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 16/4/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class ChatTopHeaderView: ReusableSupplementryView {
    
    private let label: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let sublabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        return $0
    }(UILabel())
    
    private let avatar: BadgeAvatarImageView = {
        $0.backColor = GlobalVar.theme.mainColor
        $0.badgeColor = UIColor.clear
        return $0
    }(BadgeAvatarImageView())
    
    override func setup() {
        super.setup()
        guard label.text == nil else { return }
        let room = GlobalVar.currentRoom
        let friend = room?.member
        
        label.text = friend?.displayName
        sublabel.text = friend?.country ?? ""
        
        if let friend = friend {
            avatar.loadImage(for: friend, refresh: false)
        }
        
        addSubview(avatar)
        addSubview(label)
        addSubview(sublabel)
        avatar.action {[weak self] _ in
            self?.avatar.showMediaViewer()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let containerHeight = bounds.size.height - 10
        let avatarheight = (containerHeight / 2) - 16
        let labelheight = label.font.lineHeight + 10
        avatar.frame = CGSize(avatarheight).bma_rect(inContainer: self.bounds, xAlignament: .center, yAlignment: .top, dy: 10)
        label.frame = CGSize(width: self.bounds.width, height: labelheight).bma_rect(inContainer: self.bounds, xAlignament: .center, yAlignment: .center, dy: labelheight)
        sublabel.frame = CGSize(width: self.bounds.width, height: labelheight).bma_rect(inContainer: self.bounds, xAlignament: .center, yAlignment: .center, dy: labelheight * 2)
    }
}
