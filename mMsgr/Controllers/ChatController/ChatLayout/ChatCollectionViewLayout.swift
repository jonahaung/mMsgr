//
//  MessageCollectionViewLayout.swift
//  mMsgr
//
//  Created by jonahaung on 25/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

protocol ChatCollectionViewLayoutDelegate: class {
    var chatFrcManager: ChatFrcManager { get }
    func finalizeCollectionViewUpdates(hasInserted: Bool)
}

final class ChatCollectionViewLayout: UICollectionViewFlowLayout {
    
    override class var layoutAttributesClass: AnyClass { return MsgCellLayoutAttributes.self }
    weak var layoutDelegate: ChatCollectionViewLayoutDelegate?
    
    private var chatFrcManager: ChatFrcManager? { return layoutDelegate?.chatFrcManager }
    let sizingFactory = ChatSizingFactory()
    
    private var configuredAttributes = [IndexPath: MsgCellLayoutAttributes]()

    private var itemWidth: CGFloat {
        guard let chatCollectionView = collectionView else { return 0 }
        return ceil(chatCollectionView.bounds.width - chatCollectionView.contentInset.horizontal)
    }
    
    private var availableWidth: CGFloat { return ceil(itemWidth * 0.75) }

    
    override init() {
        super.init()
        scrollDirection = .vertical
        minimumLineSpacing = 0
        register(ChatHeaderLabelView.self, forDecorationViewOfKind:  ChatHeaderLabelView.reuseIdentifier)
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        configuredAttributes.removeAll()
        print("DEINIT: MessageCollectionViewLayout")
    }
    
    override func invalidateLayout() {
        configuredAttributes.removeAll()
        super.invalidateLayout()
    }
    
    
    var hasInserted = false
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        let inserted = updateItems.filter{ $0.updateAction == .insert }
        hasInserted = inserted.count > 0
    }
}

// Overriding

extension ChatCollectionViewLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect) as? [MsgCellLayoutAttributes] else { return nil }
        for attribute in attributesArray  {
            if attribute.frame.intersects(rect){
                if attribute.representedElementCategory == .cell  {
                    configureAttributes(attribute)
                }
                
            }
        }
        
        
        return attributesArray
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attr = configuredAttributes[indexPath] {
            return attr
        }
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == ChatHeaderLabelView.reuseIdentifier {
            
            let attr = MsgCellLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
            attr.zIndex = 5
            return attr
        }
        return nil
    }
    
    func sizeOfString(string: String, font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let attString = NSAttributedString(string: string, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attString)
        var size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: .greatestFiniteMagnitude, height: font.lineHeight + 3), nil)
        let padding = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        size.width += padding.horizontal
        size.height += padding.vertical
        return size
        
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        return false
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    override func finalizeCollectionViewUpdates() {
        layoutDelegate?.finalizeCollectionViewUpdates(hasInserted: hasInserted)
    }
    

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attribute = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) as? MsgCellLayoutAttributes else { return nil }
        attribute.alpha = 1
        return attribute
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }
    
}


// Helpers

extension ChatCollectionViewLayout {
    
    func sizeFor(indexPath at: IndexPath) -> CGSize {
        guard let msg = chatFrcManager?.object(at: at) else { return .zero }
        return CGSize(width: itemWidth, height: sizingFactory.bubbleSize(for: msg, availableWidth: availableWidth, attributedText: assetFactory.attributedText(for: msg)).height)
    }
    
    private func configureAttributes(_ attribute: MsgCellLayoutAttributes) {
        
        let indexPath = attribute.indexPath
        
        guard configuredAttributes[indexPath] == nil else { return }
        guard let msg = chatFrcManager?.object(at: indexPath) else { return }
        
        attribute.isSender = msg.isSender
        attribute.bubbleSize = sizingFactory.bubbleSize(for: msg, availableWidth: availableWidth, attributedText: assetFactory.attributedText(for: msg))
       
        if msg.msgType == 1 && msg.isSender {
            guard let numberOfObjects = chatFrcManager?.numberOfItems(in: indexPath.section), numberOfObjects > 1 else { return }
            let isTopItem = indexPath.item == 0
            let isLastItem = numberOfObjects - 1 == indexPath.item

            if !isLastItem && !isTopItem {
                attribute.bubbleType = .rightMiddle
            } else {
                attribute.bubbleType = isLastItem ? .rightBottom : .rightTop
            }
            configuredAttributes[indexPath] = attribute
            
        }
    }
    
}
