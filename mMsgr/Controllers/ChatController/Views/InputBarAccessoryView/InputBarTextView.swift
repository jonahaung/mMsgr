//
//  InputBarTextView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 6/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

protocol InputBarTextViewDelegate: GrowingTextViewDelegate {
    func inputBarTextView(_ textView: InputBarTextView, isWritingText: Bool)
}

class InputBarTextView: GrowingTextView {
    
    var inputTextViewDelegate: InputBarTextViewDelegate? {
        return self.delegate as? InputBarTextViewDelegate
    }
    
    private var isWritingText: Bool = false {
        didSet {
            if oldValue != isWritingText {
                self.inputTextViewDelegate?.inputBarTextView(self, isWritingText: isWritingText)
            }
        }
    }

    
    override var text: String! {
        didSet {
            if oldValue != text {
                textDidChange()
            }
        }
    }
    override var attributedText: NSAttributedString! {
        didSet {
            if oldValue != attributedText {
                textDidChange()
            }
        }
    }
    
    override var font: UIFont? {
        didSet {
            placeHolderAttributes[.font] = font
            suggestedTextAttributes[.font] = font
        }
    }
    
    override func insertText(_ text: String) {
        super.insertText(text)
        suggestedText = nil
        textDidChange()
    }
    override func paste(_ sender: Any?) {
        suggestedText = nil
        if let string = UIPasteboard.general.string {
            insertText(string.trimmed + "\n")
        }else {
            super.paste(sender)
        }
    }
    override func cut(_ sender: Any?) {
        super.cut(sender)
        suggestedText = nil
        textDidChange()
    }
    
    var suggestedText: String? {
        didSet {
            if oldValue != suggestedText {
                setNeedsDisplay()
            }
        }
    }

    
    private var placeHolderAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.placeholderText]
    private var suggestedTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.placeholderText]
    override func commonInit() {
        super.commonInit()
        backgroundColor = .clear
        bounces = false
        showsVerticalScrollIndicator = false
        
        textContainerInset = {
            var insets = textContainerInset
            insets.left = 10
            insets.right = 5
            return insets
        }()
        
        font = UIFont.bodyFont
        minHeight = font!.lineHeight + textContainerInset.vertical + contentInset.vertical
        
        suggestedTextAttributes[.paragraphStyle] = {
            $0.lineBreakMode = .byClipping
            return $0
        }(NSMutableParagraphStyle())

        layer.cornerRadius = (minHeight*0.5).rounded()
        layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        maxHeight = (font!.lineHeight * 8) + minHeight
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        }
    }

    private var suggestedRect = CGRect.zero
    // Show placeholder if needed
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if text.isEmpty {
            let xValue = textContainerInset.left + textContainer.lineFragmentPadding
            let yValue = textContainerInset.top
            let width = rect.size.width - xValue - textContainerInset.right
            let height = rect.size.height - yValue - textContainerInset.bottom
            let placeholderRect = CGRect(x: xValue, y: yValue, width: width, height: height)
            "mMsgr ...".draw(in: placeholderRect, withAttributes: placeHolderAttributes)
            isWritingText = false
        } else {
            isWritingText = true
            if let suggestedText = self.suggestedText {
                let caretRect = self.caretRect(for: self.endOfDocument)
                
                let size = CGSize(width: rect.width - caretRect.maxX, height: minHeight)
                let diff = (caretRect.height - self.font!.lineHeight) / 2
                
                let origin = CGPoint(x: caretRect.maxX, y: caretRect.minY + diff)
                suggestedRect = CGRect(origin: origin, size: size)
                
                suggestedText.draw(in: suggestedRect, withAttributes: suggestedTextAttributes)
            }
        }
    }
}


