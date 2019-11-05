//
//  ChatSizingCache.swift
//  mMsgr
//
//  Created by jonahaung on 4/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

final class DynamicCache {
    
    fileprivate var mutableDicCache = NSCache<NSString, NSMutableDictionary>()
    
    
    // Bubble Size Cache
    func cachedBubbleSize(availableWidth: CGFloat, msg: Message) -> CGSize? {
        return mutableDicCache.object(forKey: msg.nssString)?[availableWidth] as? CGSize
    }
    
    func setBubbleSizeCache(_ messageLabelSize: CGSize, availableWidth: CGFloat, msg: Message) {
        if let existing = mutableDicCache.object(forKey: msg.nssString) {
            existing[availableWidth] = messageLabelSize
            mutableDicCache.setObject(existing, forKey: msg.nssString)
        } else {
            let new = NSMutableDictionary()
            new[availableWidth] = messageLabelSize
            mutableDicCache.setObject(new, forKey: msg.nssString)
        }
    }
    
    // Rounded Cornor Cache
    func cachedBubbleCornor(forIndexPathIndex i: Int, msg: Message) -> UInt? {
        return mutableDicCache.object(forKey: msg.nssString)?[String(i)] as? UInt
    }
    func setBubbleCornorCache(_ bubbleCornorUint: UInt, forIndexPathIndex i: Int, msg: Message) {
        if let existing = mutableDicCache.object(forKey: msg.nssString) {
            existing[String(i)] = bubbleCornorUint
            mutableDicCache.setObject(existing, forKey: msg.nssString)
        } else {
            let new = NSMutableDictionary()
            new[String(i)] = bubbleCornorUint
            mutableDicCache.setObject(new, forKey: msg.nssString)
        }
    }

    func clearCache() {
        mutableDicCache.removeAllObjects()
    }
    
}
