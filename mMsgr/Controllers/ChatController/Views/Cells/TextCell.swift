//
//  TextCell.swift
//  mMsgr
//
//  Created by jonahaung on 28/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

class TextCell: MessageCell {
    
    internal let textView: MessageTextView = {
        $0.isSelectable = true
        $0.dataDetectorTypes = [.phoneNumber, .address, .link]
        return $0
    }(MessageTextView())
    
    
    
    override func setup() {
        super.setup()
        menuImageView.image = MessageCell.menuImageTextCell
        menuImageView.sizeToFit()
        textView.addInteraction(contextMenuInterAction)
    }
    
    override func configure(_ msg: Message) {
        guard self.msg?.id != msg.id else { return }
        super.configure(msg)
        menuImageView.isHidden = msg.text2 == nil
    }
    
    override func willDisplayCell() {
        textView.attributedText = assetFactory.attributedText(for: msg)
    }
    
    override func didEndDisplayingCell() {
        textView.attributedText = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if menuImageView.isHidden { return }
        if let first = touches.first {
            let location = first.location(in: contentView)
            if menuImageView.frame.contains(location) {
                vibrate(vibration: .light)
                if let window = self.window, let text1 = self.msg?.text2 {
                    let point = first.location(in: window)
                    menuImageView.animatePressedFade { _ in
                        dropDownMessageBar.show(at: point, text: text1, duration: 5)
                    }
                }
            }
        }
    }
}

final class TextCellRight: TextCell {
    
    private let bubble = StackedBubble()
    
    override var bubbleFrame: CGRect {
        didSet {
            guard oldValue != bubbleFrame else { return }
            textView.frame = bubbleFrame
        }
    }
    
    override func setup() {
        super.setup()
        
        textView.tintColor = GlobalVar.theme.tintColor
        textView.backgroundColor = GlobalVar.theme.mainColor
        textView.layer.mask = bubble.layer
        contentView.addSubview(textView)
        bubble.radius = ceil((textView.textContainerInset.vertical + UIFont.bodyFont.pointSize) / 2)
    }
    
    override func drawBubble(_ bubbleType: BubbleType) {
        let sizeBounds = textView.bounds
        DispatchQueue.global(qos: .background).async {[weak self] in
            guard let `self` = self else { return }
            self.bubble.sizeToBounds(sizeBounds, bubbleType)
            DispatchQueue.main.async {
                guard sizeBounds == self.bubble.calculatedBounds else { return }
                self.bubble.createLayer()
            }
        }
    }
}

final class TextCellLeft: TextCell {
    
    let bubbleImageView: UIImageView = {
        return $0
    }(UIImageView())
    
    override var bubbleFrame: CGRect {
        didSet {
            guard bubbleFrame != oldValue else { return }
            bubbleImageView.frame = bubbleFrame
            textView.frame = bubbleFrame
        }
    }
    
    override func setup() {
        super.setup()
        contentView.addSubview(bubbleImageView)
        contentView.addSubview(textView)
        setBubbleImage()
    }
    
    fileprivate func setBubbleImage() {
        if traitCollection.userInterfaceStyle == .dark {
            bubbleImageView.image =  UIImage(named: "bubble-right")?.resizableImage(withCapInsets: UIEdgeInsets(round: UIFont.bodyFont.pointSize), resizingMode: .stretch)
        }else {
            bubbleImageView.image = UIImage(named: "bubble-left")?.resizableImage(withCapInsets: UIEdgeInsets(round: UIFont.bodyFont.pointSize), resizingMode: .stretch)
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) == true {
            setBubbleImage()
        }
    }
}
