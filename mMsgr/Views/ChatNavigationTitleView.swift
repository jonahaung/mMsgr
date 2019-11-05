//
//  ChatNavigationTitleView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 12/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

class ChatNavigationTitleView: UIStackView {

    
    var subtitle: String? {
        didSet {
    
            guard oldValue != subtitle else { return }
            subtitleLabel.text = self.subtitle
            setNeedsLayout()
            
        }
    }
    
    let titleLabel: UILabel = {
        $0.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .semibold)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(UILayoutPriority(999), for: .horizontal)
        $0.text = "User Name"
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = UIColor.label
        return $0
    }(UILabel())
    
    private let subtitleLabel: UILabel = {
        $0.font = UIFont.monoSpacedFont
        $0.setContentHuggingPriority(UILayoutPriority(998), for: .horizontal)
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        $0.text = "long long ago"
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = UIColor.secondaryLabel
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        distribution = .fill
        alignment = .center
        addArrangedSubview(titleLabel)
        addArrangedSubview(subtitleLabel)
    }
    
    fileprivate func updateSizeForOrientiationChange() {
        if let height = superview?.bounds.height {
            let preferred = (height * 0.5)  - 6
            if titleLabel.font.pointSize != preferred {
                titleLabel.font = titleLabel.font.withSize(preferred)
                subtitleLabel.font = subtitleLabel.font.withSize(preferred - 4)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSizeForOrientiationChange()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias Action = (ChatNavigationTitleView) -> Swift.Void
    fileprivate var actionOnTouch: Action?
    
    func action(_ closure: @escaping Action) {
        
        if actionOnTouch == nil {
            let gesture = UITapGestureRecognizer(
                target: self,
                action: #selector(ChatNavigationTitleView.actionOnTouchUpInside))
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
