//
//  ChatSizingFactory.swift
//  mMsgr
//
//  Created by jonahaung on 5/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//


import UIKit

final class ChatSizingFactory {
    
    fileprivate var mutableDicCache = [UUID: NSMutableDictionary]()

    private let textView = MessageTextView()
    
    init() {
        textView.isUserInteractionEnabled = false
        textView.isSelectable = false
    }
    
    func bubbleSize(for msg: Message, availableWidth: CGFloat, attributedText: NSAttributedString?) -> CGSize {
        
        let id = msg.id
        
        if let cachedSize = mutableDicCache[id]?[availableWidth] as? CGSize {
            return cachedSize
        } else {
            var size: CGSize
            if msg.msgType == 1 {
                
                textView.attributedText = attributedText
                size = textView.sizeThatFits(CGSize(width: availableWidth, height: .greatestFiniteMagnitude)).bma_round()
                
                textView.attributedText = nil
            } else {
                size = msg.mediaSize()
            }
            
            if let existing = mutableDicCache[id] {
                existing[availableWidth] = size
            } else {
                let new = NSMutableDictionary()
                new[availableWidth] = size
                mutableDicCache[id] = new
            }
            return size
        }
    }
    func clearCaches() {
        mutableDicCache.removeAll()
    }
    deinit {
        clearCaches()
        print("DEINIT : ChatSizingFactory")
    }
    
}
