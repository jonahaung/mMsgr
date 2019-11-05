//
//  Button.swift
//  mMsgr
//
//  Created by Aung Ko Min on 12/3/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

extension UIView {
    
    func setHuggingH(to value: Float) {
        setContentHuggingPriority(UILayoutPriority(rawValue: value), for: .horizontal)
    }
    
    func setHuggingV(to value: Float) {
        setContentHuggingPriority(UILayoutPriority(rawValue: value), for: .vertical)
    }
}
class RoundedButton: UIImageView {
      typealias Action = (RoundedButton) -> Swift.Void
    func setup() {
        isOpaque = true
        backgroundColor = nil
       
        isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        setup()
    }
    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var actionOnTouch: Action?
    
    func action(_ closure: @escaping Action) {
        self.actionOnTouch = closure
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       super.touchesEnded(touches, with: event)
        if touches.first != nil {
             self.actionOnTouch?(self)
        }
        
    }
}



class SquareButton: MyButton {
    
    var buttonHeight: CGFloat = 36 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(buttonHeight)
    }
    
    private func setup() {
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    convenience init(height: CGFloat, image: UIImage?) {
        self.init(type: .custom)
        setup()
        self.buttonHeight = height
        
        self.setImage(image, for: .normal)
    }
}
