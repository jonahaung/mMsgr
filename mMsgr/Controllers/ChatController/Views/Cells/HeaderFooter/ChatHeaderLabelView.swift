//
//  ChatHeaderLabelView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 6/11/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

class ChatHeaderLabelView : ReusableSupplementryView {
    
    private weak var imageView: UIImageView?
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        if let attr = layoutAttributes as? MsgCellLayoutAttributes {
            
        }
    }
    
    override func setup() {
        super.setup()
        let imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = bounds
        
        addSubview(imageView)
        self.imageView = imageView
        
        if self.imageView?.image == nil {
            if let id = GlobalVar.currentRoom?.member?.uid, let image = UIImage(contentsOfFile: docURL.appendingPathComponent(id).path) {
                imageView.image = image
            }
        }
        
    }
}
