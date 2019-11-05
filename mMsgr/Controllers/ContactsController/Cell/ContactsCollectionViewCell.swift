//
//  ContactsCollectionViewCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 10/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

class ContactsCollectionViewCell: CollectionViewCell {
    
    private let profileImageView: AvatarImageView = {
        $0.padding = 1
        $0.diameter = 45
        $0.backColor = UIColor.systemBackground
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(AvatarImageView())
    
    private let nameLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.adjustsFontForContentSizeCategory = true
        $0.font = UIFont.headlineFont
        return $0
    }(UILabel())
    
    private let phoneLabel: UILabel = {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.adjustsFontForContentSizeCategory = true
        $0.textColor = UIColor.quaternaryLabel
        return $0
    }(UILabel())
    
    private let accessoryImageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(systemName: "person.icloud")
        $0.tintColor = UIColor.placeholderText
        return $0
    }(UIImageView())
    
    private let seperatorView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.systemGroupedBackground
        return $0
    }(UIView())
    
    override func setup() {

        
        contentView.addSubview(seperatorView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(accessoryImageView)
        

        NSLayoutConstraint.activate([
            
            seperatorView.heightAnchor.constraint(equalToConstant: 1),
            seperatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 60),
            seperatorView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5),
            seperatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 45),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 20),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 2),
            
            phoneLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            phoneLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 17),
            
            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        
        ])
        profileImageView.tintColor = UIColor.opaqueSeparator
        
        let view = UIView()
        view.backgroundColor = UIColor.quaternarySystemFill
        selectedBackgroundView = view
    }
}

extension ContactsCollectionViewCell {
    
    func configure(_ friend: Friend) {
        let isFriend = friend.isFriend
        
        nameLabel.text = friend.displayName
        phoneLabel.text = friend.phoneNumber
        
        if isFriend {
            profileImageView.loadImage(for: friend, refresh: false)
        }else {
            profileImageView.currentImage = UIImage(systemName: "person.crop.circle.fill")
        }
        accessoryImageView.isHidden = !isFriend
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.prepareForReuse()
        nameLabel.text = nil
        phoneLabel.text = nil
    }
}
