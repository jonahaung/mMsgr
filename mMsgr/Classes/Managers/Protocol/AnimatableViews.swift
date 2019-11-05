//
//  AnimatableViews.swift
//  mMsgr
//
//  Created by Aung Ko Min on 23/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import UIKit

protocol AnimatableViews {
    var animatingView: UIView { get }
}

extension UIView: AnimatableViews {
    var animatingView: UIView {
        return self
    }
}
extension AnimatableViews {

    
    
    
    // Rotate
    func MyApp_Animate_Rotate(degrees: Double) {
        animatingView.transform = CGAffineTransform(rotationAngle: EXT_radian(degrees: degrees))
        UIView.animate(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {
            self.animatingView.transform = .identity
        })
    }
    private func EXT_radian(degrees: Double) -> CGFloat {
        return CGFloat(degrees * .pi / degrees)
    }

    // Bubble
    func MyApp_Animate_Bubble() {
        animatingView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.20, initialSpringVelocity: 3.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.animatingView.transform = .identity
        },completion: nil)
    }

    func MyApp_Animate_Pulse() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.2
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        animatingView.layer.add(pulse, forKey: "pulse")
    }

    func MyApp_Animate_Flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        animatingView.layer.add(flash, forKey: nil)
    }


    func MyApp_Animate_Shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 4
        shake.autoreverses = true

        let fromPoint = CGPoint(x: animatingView.center.x - 15, y: animatingView.center.y)
        let fromValue = NSValue(cgPoint: fromPoint)

        let toPoint = CGPoint(x: animatingView.center.x + 15, y: animatingView.center.y)
        let toValue = NSValue(cgPoint: toPoint)

        shake.fromValue = fromValue
        shake.toValue = toValue

        animatingView.layer.add(shake, forKey: "position")
    }
}
