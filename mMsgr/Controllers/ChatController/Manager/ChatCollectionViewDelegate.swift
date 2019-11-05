//
//  ChatCollectionViewDelegate.swift
//  mMsgr
//
//  Created by Aung Ko Min on 4/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

protocol ChatCollectionViewDelegateProtocol: class {
    func chatDatasource_didUpdate(timeString text: String?)
    func scrollViewInteracting(isScrolling: Bool)
    func chatDatasource_isCollectionViewIsFinishedScrolling()
    func autoLoadMoreContentIfNeeded()
    var hasMoreOldMessages: Bool { get }
}

class ChatCollectionViewDelegate: NSObject {

    weak var delegate: ChatCollectionViewDelegateProtocol?
    
    private var isScrolling: Bool = true {
        didSet {
            guard oldValue != isScrolling else { return }
            delegate?.scrollViewInteracting(isScrolling: isScrolling )
            
        }
    }
    
    private var time: String? {
        didSet {
            guard oldValue?.first != time?.first else { return }
            if let result = time?.components(separatedBy: ",").first {
                delegate?.chatDatasource_didUpdate(timeString: result)
            }
        }
    }
}


extension ChatCollectionViewDelegate: UICollectionViewDelegate {
    
    // Will/End Display
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? MessageCell {
            cell.willDisplayCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? MessageCell {
            cell.didEndDisplayingCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard isScrolling else { return }
        if let header = view as? ChatHeaderView {
            time = header.text
        }
    }
}

extension ChatCollectionViewDelegate: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let messagesFlowLayout = collectionViewLayout as? ChatCollectionViewLayout else { return CGSize(width: collectionView.bounds.width, height: 100) }
        return messagesFlowLayout.sizeFor(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let isTopHeader = section == 0 && delegate?.hasMoreOldMessages == false
        return CGSize(width: collectionView.size.width, height: isTopHeader ? 300 : 40)
    }

}


extension ChatCollectionViewDelegate {


    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isScrolling = false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.isScrolling = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            delegate?.autoLoadMoreContentIfNeeded()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.chatDatasource_isCollectionViewIsFinishedScrolling()
    }
}
