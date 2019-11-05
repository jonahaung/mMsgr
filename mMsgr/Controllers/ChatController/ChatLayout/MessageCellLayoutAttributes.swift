//
//  MessageCellLayoutAttributes.swift
//  mMsgr
//
//  Created by jonahaung on 25/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

struct ChatLayoutBlock {
    let bubbleFrame: CGRect
    let hasReadImageViewFrame: CGRect
    let statusImageViewFrame: CGRect
    let bubbleType: BubbleType
}
extension ChatLayoutBlock: Equatable {
    static func == (lhs: ChatLayoutBlock, rhs: ChatLayoutBlock) -> Bool {
        return lhs.bubbleFrame == rhs.bubbleFrame && lhs.bubbleType == rhs.bubbleType
    }
}

final class MsgCellLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var bubbleSize = CGSize.zero
    var isSender = false
    var bubbleType: BubbleType = .single
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copiedAttributes = super.copy(with: zone) as! MsgCellLayoutAttributes
        
        copiedAttributes.isSender = isSender
        copiedAttributes.bubbleSize = bubbleSize
        copiedAttributes.bubbleType = bubbleType
        return copiedAttributes
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? MsgCellLayoutAttributes {
            return
                super.isEqual(object) &&
                    attributes.isSender == isSender &&
                    attributes.bubbleSize == bubbleSize &&
                    attributes.bubbleType == bubbleType
        } else {
            return false
        }
    }
    
    func createBlock(_ completion: ((ChatLayoutBlock) -> Swift.Void )? = nil) {
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let `self` = self else { return }
            
            
            let padding = CGFloat(8)
            let spacing = CGFloat(1)
            
            let hasReadViewSize = CGSize(15)
            let statusImageViewSize = CGSize(25)
            let isSender = self.isSender
            let bubbleSize = self.bubbleSize
            let bounds = self.bounds
            
            
            let hasReadImageViewFrame: CGRect = {
                var origin = CGPoint.zero
                origin.x = isSender ? bounds.width - hasReadViewSize.width - padding : padding
                origin.y = bounds.height - hasReadViewSize.height
                return CGRect(origin: origin, size: hasReadViewSize)
            }()
            
            let bubbleFrame: CGRect = {
                var origin = CGPoint.zero
                origin.x = isSender ? hasReadImageViewFrame.minX - bubbleSize.width - spacing : hasReadImageViewFrame.maxX + spacing
                return CGRect(origin: origin, size: bubbleSize)
            }()
            
            let statusImageViewFrame: CGRect = {
                var origin = CGPoint.zero
                origin.x = isSender ? bubbleFrame.minX - statusImageViewSize.width - spacing: bubbleFrame.maxX + spacing
                origin.y = bounds.height - statusImageViewSize.height - spacing
                return CGRect(origin: origin, size: statusImageViewSize)
            }()
            
            DispatchQueue.main.async {
                completion?(ChatLayoutBlock(bubbleFrame: bubbleFrame, hasReadImageViewFrame: hasReadImageViewFrame, statusImageViewFrame: statusImageViewFrame, bubbleType: self.bubbleType))
            }
            
        }
        
    }
}


public enum BubbleType {
    case rightTop, rightMiddle, rightBottom, single
    
    var rectCornors: UIRectCorner {
        switch self {
        case .single:
            return .allCorners
        case .rightTop:
            return UIRectCorner(arrayLiteral: [.bottomLeft, .topLeft, .topRight])
        case .rightMiddle:
            return UIRectCorner(arrayLiteral: [.bottomLeft, .topLeft])
        case .rightBottom:
            return UIRectCorner(arrayLiteral: [.bottomLeft, .topLeft, .bottomRight])
        }
        
    }
    
    var maskCornors: CACornerMask {
        switch self {
        case .single:
            return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        case .rightTop:
            return [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        case .rightMiddle:
            return [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        case .rightBottom:
            return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
        }
        
    }
}


