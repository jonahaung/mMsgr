//
//  ChatCollectionView.swift
//  mMsgr
//
//  Created by jonahaung on 12/6/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

final class ChatCollectionView: UICollectionView, MainCoordinatorDelegatee {
    
    
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        clipsToBounds = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        remembersLastFocusedIndexPath = true
        bounces = true
        alwaysBounceVertical = true
        keyboardDismissMode = .none
        allowsMultipleSelection = false
        showsVerticalScrollIndicator = true
        contentInsetAdjustmentBehavior = .never
        allowsSelection = false
        preservesSuperviewLayoutMargins = false
        insetsLayoutMarginsFromSafeArea = false
        automaticallyAdjustsScrollIndicatorInsets = true
        isExclusiveTouch = true
        
        register(TextCellRight.self)
        register(TextCellLeft.self)
        register(AudioCell.self)
        register(PhotoVideoCell.self)
        register(GifCell.self)
        register(LocationCell.self)
        register(RichLinkCell.self)
        register(SystemMsgCell.self)
        register(ChatTopHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        register(ChatHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        setBackgroundImage()
    }
    
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DEINIT: ChatCollectionView")
    }
    
    
}

extension UICollectionView {
    
    func lastIndexPath() -> IndexPath? {
        guard self.numberOfSections > 0 && self.numberOfItems(inSection: 0) > 0 else { return nil }
        let sectionIndex = self.numberOfSections - 1
        let itemIndex = self.numberOfItems(inSection: sectionIndex) - 1
        return IndexPath(item: itemIndex, section: sectionIndex)
    }
    func isScrolledAtBottom() -> Bool {
        guard let indexPath = lastIndexPath() else { return true }
        return self.isIndexPathVisible(indexPath, atTop: false)
    }
    
    func isCloseToBottom() -> Bool {
        guard self.contentSize.height > 0 else { return true }
        return (self.visibleRect().maxY / contentSize.height) > (1 - 0.05)
    }
    
    func isScrolledAtTop() -> Bool {
        guard numberOfSections > 0 && numberOfItems(inSection: 0) > 0 else { return false }
        let firstIndexPath = IndexPath(item: 0, section: 0)
        return self.isIndexPathVisible(firstIndexPath, atTop: true)
    }
    
    func rectAtIndexPath(_ indexPath: IndexPath) -> CGRect? {
        return collectionViewLayout.layoutAttributesForItem(at: indexPath)?.frame
    }
    
    func isCloseToTop() -> Bool {
        let contentHeight = contentSize.height
        guard contentHeight > 0 else { return true }
        let visible = visibleRect()
        
        let factor = (visible.minY / contentHeight) * 100
        let maxFactor = (visible.maxY / contentHeight) * 100
        print(factor, maxFactor)
        return factor < 0
    }
    
    func isIndexPathVisible(_ indexPath: IndexPath, atTop: Bool) -> Bool {
        if let attributes = collectionViewLayout.layoutAttributesForItem(at: indexPath) {
            let visibleRect = self.visibleRect()
            let intersection = visibleRect.intersection(attributes.frame)
            if atTop {
                return abs(intersection.minY - attributes.frame.minY) < GlobalVar.bma_epsilon
            } else {
                return abs(intersection.maxY - attributes.frame.maxY) < GlobalVar.bma_epsilon
            }
        }
        return false
    }
    
    func visibleRect() -> CGRect {
        let contentSize = self.contentSize
        return CGRect(x: 0, y: contentOffset.y, width: bounds.width, height: min(contentSize.height, bounds.height))
    }
    
    func scrollToPreservePosition(oldRefRect: CGRect?, newRefRect: CGRect?) {
        guard let oldRefRect = oldRefRect, let newRefRect = newRefRect else {
            return
        }
        let diffY = newRefRect.minY - oldRefRect.minY
        self.contentOffset = CGPoint(x: 0, y: self.contentOffset.y + diffY)
    }
    
    
    func scrollToItem(with indexPath: IndexPath, position: UICollectionView.ScrollPosition = .bottom, animated: Bool = true) {
        
        guard let rect = self.rectAtIndexPath(indexPath) else { return }
        
        if animated {
            let pageHeight = self.bounds.height
            let twoPagesHeight = pageHeight
            let isScrollingUp = rect.minY < self.contentOffset.y
            
            if isScrollingUp {
                let isNeedToScrollUpMoreThenTwoPages = rect.minY < self.contentOffset.y - twoPagesHeight
                if isNeedToScrollUpMoreThenTwoPages {
                    let lastPageOriginY = self.contentSize.height - pageHeight
                    var preScrollRect = rect
                    preScrollRect.origin.y = min(lastPageOriginY, rect.minY + pageHeight)
                    self.scrollRectToVisible(preScrollRect, animated: false)
                }
            } else {
                let isNeedToScrollDownMoreThenTwoPages = rect.minY > self.contentOffset.y + twoPagesHeight
                if isNeedToScrollDownMoreThenTwoPages {
                    var preScrollRect = rect
                    preScrollRect.origin.y = max(0, rect.minY - pageHeight)
                    self.scrollRectToVisible(preScrollRect, animated: false)
                }
            }
        }
        
        self.scrollToItem(at: indexPath, at: position, animated: animated)
    }
}

extension UICollectionView {
    
    var isSafeToInteract: Bool {
        let isInteracting = self.panGestureRecognizer.numberOfTouches > 0
        let isBouncingAtTop = isInteracting && self.contentOffset.y < -self.contentInset.top
        return !isBouncingAtTop
    }
}
