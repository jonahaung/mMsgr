//
//  ChatViewController+Keyboard.swift
//  mMsgr
//
//  Created by jonahaung on 29/9/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

extension ChatViewController {
    
    func adjustInsetsToSafeArea() {
        var insets = view.safeAreaInsets
        insets.bottom = bottomSpaceFromInputBar()
        collectionView.contentInset = insets
    }
    
    @objc func handleOrientationChange() {
        navigationTitleView?.setNeedsLayout()
        adjustInsetsToSafeArea()
        layoutTimeLabel()
        
    }
    
    func updateCollectionViewContentInsets(shouldAdjustContentOffset: Bool) {
        
        if manager?.isCollectionViewIsScrolling == true { return }
        
        
        let newInsetBottom = bottomSpaceFromInputBar()
        
        let insetBottomDiff = newInsetBottom - collectionView.contentInset.bottom
        
        if abs(insetBottomDiff) < 5 { return }
        
        collectionView.contentInset.bottom = newInsetBottom
        
        guard didLayoutSubviews && shouldAdjustContentOffset && collectionView.isSafeToInteract else { return }
        
        manager?.isCollectionViewIsScrolling = true
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        let prevContentOffsetY = collectionView.contentOffset.y
        
        let newContentOffsetY: CGFloat = {
            let minOffset = -(self.view.safeAreaInsets.top+contentSize.height)
            let maxOffset = contentSize.height - (self.collectionView.bounds.height - newInsetBottom)
            let targetOffset = prevContentOffsetY + insetBottomDiff
            return ceil(max(min(maxOffset, targetOffset), minOffset))
        }()
        var offset = self.collectionView.contentOffset
        offset.y = newContentOffsetY
        
        self.collectionView.setContentOffset(offset, animated: true)
    }
    
    func bottomSpaceFromInputBar() -> CGFloat {
        let blurredView = inputBar.blurView
        let trackingViewRect = view.convert(blurredView.bounds, from: blurredView)
        return max(trackingViewRect.height, view.bounds.height - trackingViewRect.minY).rounded()
    }
}
