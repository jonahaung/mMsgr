//
//  BadgeStackView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 5/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class BadgeStackView: CustomStackView {

    
    var isTyping = false {
        didSet {
            if oldValue != isTyping {
                if isTyping && !arrangedSubviews.contains(typingView){
                    insertArrangedSubview(typingView, at: arrangedSubviews.count - 1)
                    SoundManager.playSound(tone: .Typing)
                    typingView.startAnimating()
                }else if !isTyping && arrangedSubviews.contains(typingView){
                    removeArrangedSubview(typingView)
                    typingView.removeFromSuperview()
                    typingView.stopAnimating()
                }
            }
        }
    }
    
    let typingView = LoaderView()
    
    var showScrollButton = false {
        didSet {
            if oldValue != showScrollButton {
                scrollButton.isHidden = !self.showScrollButton
            }
        }
    }
    private let scrollButton = BadgeImageView(_badgeType: .ScrollToBottom)
    
    let label: UILabel = {
        $0.isOpaque = true
        $0.font = UIFont.myanmarFontSmaller
        $0.textColor = UIColor.myAppYellow
        $0.setHuggingH(to: 600)
        $0.setHuggingV(to: 700)
        return $0
    }(UILabel())
    
    override func setup() {
        super.setup()
        isUserInteractionEnabled = true
        axis = .horizontal
        distribution = .fill
        alignment = .bottom
        spacing = UIStackView.spacingUseSystem
    
        scrollButton.tintColor = .link
    
        addArrangedSubview(scrollButton)
    
        addArrangedSubview(label)
        addArrangedSubview(MySpacer())
        
        tintColor = UIColor.n1DarkGreyColor
        
        scrollButton.isHidden = true
        
    }

   
    // Action
    
    typealias Action = (BadgeType) -> Swift.Void
    
    private var actionOnTouch: Action?

    func action(_ closure: @escaping Action) {
        actionOnTouch = closure
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if label.frame.contains(point) {
            return true
        }
        for view in arrangedSubviews where view is BadgeImageView {
            let expendedFrame = view.frame.inset(by: UIEdgeInsets(round: -5))
            if expendedFrame.contains(point) {
                return true
            }
        }
        return false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    
        if let first = touches.first {
            let point = first.location(in: self)
            if label.frame.contains(point) {
                SoundManager.playSound(tone: .Tock)
                self.actionOnTouch?(.Label)
                return
            }
            for view in arrangedSubviews where view is BadgeImageView {
                if let badgeView = view as? BadgeImageView {
                    let expendedFrame = badgeView.frame.inset(by: UIEdgeInsets(round: -5))
                    if expendedFrame.contains(point) {
                        SoundManager.playSound(tone: .Tock)
                        badgeView.animatePressedFade {[weak self] _ in
                            self?.actionOnTouch?(badgeView.badgeType)
                        }
                        break
                    }
                }
                
            }
        }
    }
    
    enum BadgeType {
        
        
        case ScrollToBottom, Label, NewMsg
        
        var mainImage: UIImage? {
            switch self {
            case .ScrollToBottom:
                return UIImage(systemName: "chevron.up.chevron.down")?.applyingSymbolConfiguration(.init(pointSize: 35, weight: .thin))

            case .NewMsg:
                return UIImage(systemName: "envelope.fill")
            case .Label:
                return nil
            }
        }
    
    
    }
    
    
}

final class BadgeImageView: UIImageView {
    

    let badgeType: BadgeStackView.BadgeType
    
    init(_badgeType: BadgeStackView.BadgeType) {
        badgeType = _badgeType
        super.init(image: _badgeType.mainImage)
        isOpaque = true
        backgroundColor = nil
        isUserInteractionEnabled = false
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
