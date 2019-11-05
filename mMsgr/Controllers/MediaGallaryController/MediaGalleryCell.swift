//
//  MediaGalleryCell.swift
//  mMsgr
//
//  Created by jonahaung on 14/8/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

class MediaGalleryCell: CollectionViewCell {
    
    var msg: Message?
    
    override var isSelected: Bool {
        didSet {
            
            checkMark.isHidden = !isSelected
            imageView.layer.borderWidth = isSelected ? 2 : 0
            if isSelected {
                vibrate(vibration: .selection)
            }
        }
    }
    
    let imageView: UIImageView = {
        let x = UIImageView(frame: .zero)
        x.contentMode = .center
        x.layer.cornerRadius = 8
        x.clipsToBounds = true
        x.layer.borderColor = UIColor.myAppYellow.cgColor
        return x
    }()
    
    let checkMark: UIImageView = {
        let x = UIImageView(image: UIImage(systemName: "circle.fill"))
        x.tintColor = UIColor.myAppYellow
        x.isHidden = true
        return x
    }()
    
    let playButtonView: UIImageView = {
        let x = UIImageView()
        x.image = #imageLiteral(resourceName: "Video Message")
        x.isHidden = true
        return x
    }()

    override func setup() {
        super.setup()
        contentView.addSubview(imageView)
        contentView.addSubview(playButtonView)
        contentView.addSubview(checkMark)
        imageView.fillSuperview()
        
        playButtonView.centerInSuperview()
        
        checkMark.addConstraints(contentView.topAnchor, left: nil, bottom: nil, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        msg = nil
        imageView.image = nil
    }
    
    func configure(_ msg: Message) {
        self.msg = msg
        self.imageView.image = nil
        if msg.msgType == MsgType.Audio.rawValue {
            imageView.image = #imageLiteral(resourceName: "PlayButton")
        } else {
            let localUrl = msg.mediaURL
            
            guard let thumbUrl = localUrl else { return }
            
            if let storedImage = UIImage(contentsOfFile: thumbUrl.path) {
                self.imageView.image = storedImage
            }
        }
        playButtonView.isHidden = msg.msgType != 3
    }
}
