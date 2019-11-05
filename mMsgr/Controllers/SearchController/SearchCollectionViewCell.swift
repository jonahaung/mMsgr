//
//  SearchCollectionViewCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class SearchCollectionViewCell: CollectionViewCell {
    
    private let profileImageView: AvatarImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(AvatarImageView())
    
    private let nameLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.adjustsFontForContentSizeCategory = true
        $0.font = UIFont.headlineFont
        return $0
    }(UILabel())
    
    private let seperatorView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.systemGroupedBackground
        return $0
    }(UIView())

    
    override func setup() {
        super.setup()
        
        let padding = UIEdgeInsets(top: 3, left: 10, bottom: -3, right: -25)
        
    
        contentView.addSubview(seperatorView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            seperatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 60),
            seperatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            seperatorView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            seperatorView.heightAnchor.constraint(equalToConstant: 1),
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding.top),
            profileImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: padding.bottom),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor, multiplier: 1),
            
            nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 25),

            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
    }
    
    func configure(for friend: Friend) {
        self.nameLabel.text = friend.displayName
        self.profileImageView.loadImage(for: friend, refresh: false)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.currentId = nil
        profileImageView.currentImage = nil
    }
}
