//
//  FavoriteDatasource.swift
//  mMsgr
//
//  Created by Aung Ko Min on 22/6/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
class FavoriteCell: CollectionViewCell {

    let avatarImageView: BadgeAvatarImageView = {
        $0.padding = 1
        $0.isUserInteractionEnabled = false
        $0.backColor = UIColor.systemBlue
        $0.badgeColor = UIColor.myAppYellow
        return $0
    }(BadgeAvatarImageView())
    
    private let insets = UIEdgeInsets(round: 4)
    override func setup() {
        super.setup()
        
        contentView.addSubview(avatarImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.frame = contentView.bounds.inset(by: insets)
    }
    
    private var isToday = false {
        didSet {
            guard isToday != oldValue else { return }
            let color = isToday ? UIColor.systemGreen : UIColor.myAppYellow
            avatarImageView.badgeColor = color
        }
    }
    
    
    func configure(_ friend: Friend?) {
        guard let friend = friend else { return }
    
        if let date = friend.lastAccessedDate {
            let timeAgo = MessageDateFormatter.shared.timeAgo(from: date)
            avatarImageView.badge = timeAgo
            isToday = timeAgo.lastCharacterAsString == "m"
        }
        avatarImageView.loadImage(for: friend, refresh: false)
    }
    func reset() {
        avatarImageView.currentImage = nil
    }
}
