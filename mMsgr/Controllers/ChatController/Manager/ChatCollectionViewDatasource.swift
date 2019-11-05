//
//  ChatCollectionViewDatasource.swift
//  mMsgr
//
//  Created by Aung Ko Min on 4/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

protocol ChatCollectionViewDatasourceDelegate: class {
    
    var hasMoreOldMessages: Bool { get }
    var sectionCount: Int { get }
    func numberOfItems(in section: Int) -> Int
    func msg(at indexPath: IndexPath) -> Message
}

final class ChatCollectionViewDatasource: NSObject {
    
    weak var delegate: ChatCollectionViewDatasourceDelegate?
    
    deinit {
        print("DEINIT: ChatDataSource")
    }
}

/**
 CollectionView Datasource / Delegate
 */
extension ChatCollectionViewDatasource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return delegate?.sectionCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,  numberOfItemsInSection section: Int) -> Int {
        return delegate?.numberOfItems(in: section) ?? 0
    }
    
    // Cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let msg = delegate?.msg(at: indexPath) else {
            return UICollectionViewCell()
        }
        
        switch msg.messageType {
        case .Text:
            if msg.isSender {
                let msgCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellRight.reuseIdentifier, for: indexPath) as! TextCellRight
                msgCell.configure(msg)
                return msgCell
            }else {
                let msgCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCellLeft.reuseIdentifier, for: indexPath) as! TextCellLeft
                msgCell.configure(msg)
                return msgCell
            }
        case .Photo, .Video:
            let msgCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoVideoCell.reuseIdentifier, for: indexPath) as! PhotoVideoCell
            msgCell.configure(msg)
            return msgCell
        case .Location:
            let msgCell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
            msgCell.configure(msg)
            return msgCell
        case .Audio:
            let msgCell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioCell.reuseIdentifier, for: indexPath) as! AudioCell
            msgCell.configure(msg)
            return msgCell
        case .Face, .Gif:
            let msgCell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCell.reuseIdentifier, for: indexPath) as! GifCell
            msgCell.configure(msg)
            return msgCell
        case .RichLink:
            let msgCell = collectionView.dequeueReusableCell(withReuseIdentifier: RichLinkCell.reuseIdentifier, for: indexPath) as! RichLinkCell
            msgCell.configure(msg)
            return msgCell
        case .System:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SystemMsgCell.reuseIdentifier, for: indexPath) as! SystemMsgCell
            cell.configure(msg: msg)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let isTopHeader = indexPath.section == 0 && delegate?.hasMoreOldMessages == false
        if isTopHeader {
            let view: ChatTopHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(elementKind: kind, forIndexPath: indexPath)
            return view
        } else {
            let header: ChatHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(elementKind: kind, forIndexPath: indexPath)
            if indexPath.item == 0, let msg = delegate?.msg(at: indexPath) {
                header.configure(msg: msg)
            }
            return header
            
        }
    }
}
