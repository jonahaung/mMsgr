//
//  GrowingTextView.swift
//  Pods
//
//  Created by Kenneth Tsang on 17/2/2016.
//  Copyright (c) 2016 Kenneth Tsang. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol GrowingTextViewDelegate: UITextViewDelegate {
    @objc optional func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat)
   
}

open class GrowingTextView: UITextView {
    
    private var heightConstraint: NSLayoutConstraint?
    
    open var maxLength: Int = 0
    
    open var trimWhiteSpaceWhenEndEditing: Bool = false
    
    open var minHeight: CGFloat = 0
    
    open var maxHeight: CGFloat = 0 {
        didSet { forceLayoutSubviews() }
    }
    
    
    // Initialize
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        contentMode = .redraw
        associateConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextView.textDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing(_:)), name: UITextView.textDidEndEditingNotification, object: self)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: minHeight)
    }
    
    private func associateConstraints() {
        // iterate through all text view's constraints and identify
        // height,from: https://github.com/legranddamien/MBAutoGrowingTextView
        for constraint in constraints {
            if (constraint.firstAttribute == .height) {
                if (constraint.relation == .equal) {
                    heightConstraint = constraint;
                }
            }
        }
    }
    
    // Calculate and adjust textview's height
    private var oldText: String = ""
    private var oldSize: CGSize = .zero
    
    func forceLayoutSubviews() {
        oldSize = .zero
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private var shouldScrollAfterHeightChanged = false
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if text == oldText && bounds.size == oldSize { return }
        oldText = text
        oldSize = bounds.size
        
        let size = sizeThatFits(CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        var height = size.height
        
        // Constrain minimum height
        height = minHeight > 0 ? max(height, minHeight) : height
        
        // Constrain maximum height
        height = maxHeight > 0 ? min(height, maxHeight) : height
        
        // Add height constraint if it is not found
        if (heightConstraint == nil) {
            heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
            addConstraint(heightConstraint!)
        }
        
        // Update height constraint if needed
        if height != heightConstraint!.constant {
            shouldScrollAfterHeightChanged = true
            heightConstraint!.constant = height
            if let delegate = delegate as? GrowingTextViewDelegate {
                delegate.textViewDidChangeHeight?(self, height: height)
            }
        } else if shouldScrollAfterHeightChanged {
            shouldScrollAfterHeightChanged = false
            scrollToCorrectPosition()
            ensureCaretToTheEnd()
        }
    }
    
    func scrollToCorrectPosition() {
        if self.isFirstResponder {
            self.scrollRangeToVisible(NSMakeRange(-1, 0)) // Scroll to bottom
        } else {
            self.scrollRangeToVisible(NSMakeRange(0, 0)) // Scroll to top
        }
    }
    
    
    
    // Trim white space and new line characters when end editing.
    @objc func textDidEndEditing(_ notification: Notification) {
        if let sender = notification.object as? GrowingTextView, sender == self {
            if trimWhiteSpaceWhenEndEditing {
                text = text?.trimmingCharacters(in: .whitespacesAndNewlines)
                setNeedsDisplay()
            }
            scrollToCorrectPosition()
        }
    }
    
    // Limit the length of text
    @objc func textDidChange(_ notification: Notification) {
        if let sender = notification.object as? GrowingTextView, sender == self {
            textDidChange()
        }
    }
    func textDidChange() {
//        if maxLength > 0 && text.count > maxLength {
//            let endIndex = text.index(text.startIndex, offsetBy: maxLength)
//            text = String(text[..<endIndex])
//            undoManager?.removeAllActions()
//        }
        setNeedsDisplay()
    }
}

