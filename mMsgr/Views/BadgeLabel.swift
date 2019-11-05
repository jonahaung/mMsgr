//
//  BadgeLabel.swift
//  mMsgr
//
//  Created by Aung Ko Min on 27/7/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class BadgeLabel: CustomView {
    
    
    override var frame: CGRect {
        didSet {
            configureBorder()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            configureBorder()
        }
    }
    
    var fontSize: CGFloat = 0 {
        didSet {
            guard oldValue != fontSize else { return }
            label.font = UIFont.systemFont(ofSize: max(8, fontSize), weight: .medium)
            padding = (fontSize / 3)
        }
    }
    
    let label = UILabel()
    
    var padding = CGFloat(0)
    
    override var intrinsicContentSize: CGSize {
        let preferred = label.intrinsicContentSize.width + padding*2
        return CGSize(preferred).bma_round()
    }
    
    override func setup() {
        super.setup()
        isOpaque = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .medium)
        label.textColor = UIColor.tertiarySystemBackground
        label.textAlignment = .center
        backgroundColor = UIColor.systemGray
        
        configureBorder()
    }
    
    func configureBorder() {
        let radius = bounds.width / 2.0
        layer.cornerRadius = radius
        setNeedsDisplay()
    }
    
    typealias Action = (BadgeLabel) -> Swift.Void
    
    fileprivate var actionOnTouch: Action?
    
    func action(_ closure: @escaping Action) {
        
        if actionOnTouch == nil {
            let gesture = UITapGestureRecognizer(
                target: self,
                action: #selector(BadgeLabel.actionOnTouchUpInside))
            gesture.numberOfTapsRequired = 1
            gesture.numberOfTouchesRequired = 1
            self.addGestureRecognizer(gesture)
            self.isUserInteractionEnabled = true
        }
        self.actionOnTouch = closure
    }
    
    @objc internal func actionOnTouchUpInside() {
        actionOnTouch?(self)
    }
}
