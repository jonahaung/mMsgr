//
//  OKConversationAssetFactory.swift
//  ScrollingPerformance
//
//  Copyright © 2017 OkCupid. All rights reserved.
//

import UIKit
import LinkPresentation

let assetFactory = ChatAssetFactory()

extension UUID {
    var nsString: NSString {
        return NSString(string: self.uuidString)
    }
}
final class ChatAssetFactory {
    
    private var attributedTextCache = [UUID: NSAttributedString]()
    private var imageCache = NSCache<NSString, UIImage>()

    func attributedText(for msg: Message?) -> NSAttributedString? {
        guard let msg = msg, msg.msgType == 1 else { return nil }
        let id = msg.id
        if let x = attributedTextCache[id] {
            return x
        } else {
            let attributedText = msg.getAttributedText()
            attributedTextCache[id] = attributedText
            return attributedText
        }
    }
    
    func attributedText(for msgId: UUID?) -> NSAttributedString? {
        guard let id = msgId else { return nil }
        return attributedTextCache[id]
    }
    
    func image(for msgId: UUID?) -> UIImage? {
        guard let id = msgId else { return nil }
        return imageCache.object(forKey: id.nsString)
    }
    func setImage(for msgId: UUID, image: UIImage) {
        imageCache.setObject(image, forKey: msgId.nsString)
    }
    
    func clearCaches(){
        attributedTextCache.removeAll()
        imageCache.removeAllObjects()
    }
    deinit {
        clearCaches()
        print("DEINIT : ChatAssetFactory")
    }
}

extension UIImage: NSDiscardableContent {
    
    public func beginContentAccess() -> Bool {
        return true
    }
    public func endContentAccess() {}
    public func discardContentIfPossible() {}
    public func isContentDiscarded() -> Bool {
        return false
    }
}

extension NSAttributedString: NSDiscardableContent {
    
    public func beginContentAccess() -> Bool {
        return true
    }
    public func endContentAccess() {}
    public func discardContentIfPossible() {}
    public func isContentDiscarded() -> Bool {
        return false
    }
}


extension NSMutableDictionary: NSDiscardableContent {
    
    public func beginContentAccess() -> Bool {
        return true
    }
    public func endContentAccess() {}
    public func discardContentIfPossible() {}
    public func isContentDiscarded() -> Bool {
        return false
    }
}
