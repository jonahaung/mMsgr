//
//  InboxCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 10/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class InboxCell: CollectionViewCell {
    
    private let nameLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.adjustsFontForContentSizeCategory = true
        $0.font = UIFont.headlineFont 
        return $0
    }(UILabel())
    
    private let timeLabel: UILabel = {
        $0.adjustsFontForContentSizeCategory = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.preferredFont(forTextStyle: .footnote)
        $0.textColor = UIColor.tertiaryLabel
        return $0
    }(UILabel())
    
    private let msgTextLabel: UILabel = {
        $0.adjustsFontForContentSizeCategory = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.calloutFont
        $0.numberOfLines = 4
        $0.textColor = UIColor.secondaryLabel
        return $0
    }(UILabel())
    
    private let accessoryImageView: UIImageView = {
        $0.preferredSymbolConfiguration = .init(pointSize: 15, weight: .thin)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())
    
    private let seperatorView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.systemGroupedBackground
        return $0
    }(UIView())
    
    private let profileImageView: AvatarImageView = {
        $0.padding = 1
        $0.backgroundColor = UIColor.quaternarySystemFill
        $0.isUserInteractionEnabled = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(AvatarImageView())
    
    private let senderImageView: AvatarImageView = {
        $0.backColor = UIColor.systemGroupedBackground
        $0.padding = 1
        $0.diameter = 25
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(AvatarImageView())
    
    override func setup() {
        super.setup()
        accessoryImageView.preferredSymbolConfiguration = .init(pointSize: 14, weight: .regular)
        contentView.addSubview(seperatorView)
        contentView.addSubview(profileImageView)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(msgTextLabel)
        contentView.addSubview(accessoryImageView)
        contentView.addSubview(senderImageView)
        
        let inset = CGFloat(20)
        
        NSLayoutConstraint.activate([
            
            seperatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10 + 60),
            seperatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            seperatorView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -(inset)),
            seperatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            profileImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0),
            nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10),
            
            timeLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -inset),
            timeLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            
            msgTextLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10),
            msgTextLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            msgTextLabel.rightAnchor.constraint(equalTo: accessoryImageView.leftAnchor),
            msgTextLabel.bottomAnchor.constraint(lessThanOrEqualTo: seperatorView.topAnchor, constant: -10),
            
            accessoryImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5),
            accessoryImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -inset),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 20),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 20),
            
            senderImageView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            senderImageView.rightAnchor.constraint(equalTo: profileImageView.rightAnchor),
            senderImageView.widthAnchor.constraint(equalToConstant: 26),
            senderImageView.heightAnchor.constraint(equalToConstant: 26)
        ])
        let timeLabelLeft = timeLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor)
        timeLabelLeft.priority = UILayoutPriority(700)
        timeLabelLeft.isActive = true
        
        let view = UIView()
        view.backgroundColor = UIColor.quaternarySystemFill
        selectedBackgroundView = view
    }
    
    var msg: Message? {
        didSet {
            nameLabel.text = name
            timeLabel.text = time
            msgTextLabel.text = msgText
            accessoryImageView.image = UIImage(systemName: hasReadImageName)?.withTintColor(accessoryTintColor, renderingMode: .alwaysOriginal)
            
            if let sender = msg?.sender {
                profileImageView.loadImage(for: sender, refresh: false)
                senderImageView.loadImage(for: sender, refresh: false)
            }else {
                if let friend = msg?.room?.member {
                    profileImageView.loadImage(for: friend, refresh: false)
                }
                senderImageView.loadImageForCurrentUser(refresh: false)
            }
            UIView.performWithoutAnimation {
                self.layoutIfNeeded()
            }
        }
    }
    private var accessoryTintColor: UIColor {
        guard let msg = self.msg else { return UIColor.systemRed }
        return msg.hasRead ? UIColor.n1MidGreyColor : msg.isSender ? UIColor.myAppYellow : .systemBlue
    }
    private var name: String? {
        return msg?.room?.name
    }
    private var msgText: String? {
        if let text = msg?.text {
            return text
        }
        return nil
    }
    
    private var time: String? {
        if let date = msg?.date {
            return MessageDateFormatter.shared.string(from: date)
        }
        return nil
    }
    
    private var hasReadImageName: String {
        guard let msg = msg else { return "" }
        return msg.isSender ?
            (msg.hasRead ? "checkmark.circle.fill" : "arrowshape.turn.up.right.fill")
            :
            (msg.hasRead ? "checkmark.circle" : "arrowshape.turn.up.left.fill")
    }
    
    fileprivate func reset() {
        msg = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
}
