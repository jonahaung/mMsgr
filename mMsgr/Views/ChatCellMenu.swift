//
//  ChatCellMenu.swift
//  mMsgr
//
//  Created by Aung Ko Min on 20/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class ChatCellMenu: UIStackView {
    
    let one = UIButton(type: .infoDark)
    let two = UIButton(type: .detailDisclosure)
    let three = UIButton(type: .close)
    private var timer: Timer?
    let blurView: UIVisualEffectView = {
        return $0
    }(UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial)))
    var buttons: [UIView] {
        return [one, two, three]
    }
    override var intrinsicContentSize: CGSize {
        return CGSize(width: CGFloat(40*arrangedSubviews.count), height: 40)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
        clipsToBounds = true
        layer.cornerRadius = 5
        axis = .horizontal
        distribution = .fillEqually
        alignment = .fill
        buttons.forEach{ addArrangedSubview($0) }
        
    }
    
    private let insets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurView.frame = bounds
        
    }
    
    func show(at point: CGPoint, text: String, duration: TimeInterval) {
        SoundManager.playSound(tone: .Tock)
        guard let window = AppDelegate.sharedInstance.window  else { return }
        
        if duration > 0 {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.hide), userInfo: nil, repeats: false)
        }
        
        invalidateIntrinsicContentSize()
        let size = intrinsicContentSize
        
        let origin = CGPoint(x: point.x - (width/2), y: point.y - height - 10)
        self.frame = CGRect(origin: origin, size: size)
        
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        if self.superview == nil {
            window.addSubview(self)
        }
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.9, options: [.beginFromCurrentState, .allowUserInteraction, .allowAnimatedContent], animations: {
            self.transform = .identity
        })
    }
    
    @objc func hide() {
        timer?.invalidate()
        guard self.superview != nil  else { return }
        self.removeFromSuperview()
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
let chatCellMenu = ChatCellMenu()
