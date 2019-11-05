//
//  UICollectionView+Ext.swift
//  mMsgr
//
//  Created by jonahaung on 12/10/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

extension UICollectionView{

    func scrollToBottom(animated: Bool, completion: (() -> Void)? = nil) {

        var offset = contentOffset
        offset.y = max(-contentInset.top, collectionViewLayout.collectionViewContentSize.height - frame.height + contentInset.bottom)
        
        setContentOffset(offset, animated: animated)
        completion?()
    }
    
}

extension UICollectionViewCell {
    
    @objc func reload() {
        
    }
}

