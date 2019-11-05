//
//  UIViewExtensions.swift
//  SwifterSwift
//
//  Created by Omar Albeik on 8/5/16.
//  Copyright © 2016 Omar Albeik. All rights reserved.
//

import UIKit

extension UIView {
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shouldRasterize = true
        layer.rasterizationScale = UIMainScreenScale
    }
    
    func applyGradient(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint? = nil, endPoint: CGPoint? = nil) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations
        if let startPoint = startPoint, let endPoint = endPoint {
            gradient.startPoint = startPoint
            gradient.endPoint = endPoint
        }
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    public enum ViewSide {
        case top
        case right
        case bottom
        case left
    }
}

public extension UIView {
    
    /// SwifterSwift: Get view's parent view controller
    var EXT_parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    

    
    func animatePressRotate(_ completion: (() -> Void)? = nil) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: GlobalVar.animationOption, animations: {
            self.transform = CGAffineTransform(rotationAngle: 1*CGFloat.pi)
        })  { _ in
            self.transform = .identity
            completion?()
        }
    }
    
    func animatePressedFade(_ completion: ((Bool) -> Void)? = nil) {
        if self.transform.isIdentity {
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.2, delay: 0, options: GlobalVar.animationOption, animations: {
                self.transform = .identity
            }) { done in
                completion?(done)
            }
        } else {
            completion?(false)
        }
        
    }
    
    func animateCellSelect(_ completion: (() -> Void)? = nil) {
        if self.transform.isIdentity {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.2, delay: 0, options: GlobalVar.animationOption, animations: {
                self.transform = .identity
            }) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }
}

extension UIView {

    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func constraint(equalTo size: CGSize) {
        guard superview != nil else { return }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }

    
    func fillSuperview() {
        guard let superview = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
    func centerInSuperview() {
        guard let superview = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
    }
    
    @discardableResult
    func addConstraints(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        
        if self.superview == nil {
            return []
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        if let top = top {
            let constraint = topAnchor.constraint(equalTo: top, constant: topConstant)
            constraint.identifier = "top"
            constraints.append(constraint)
        }
        
        if let left = left {
            let constraint = leftAnchor.constraint(equalTo: left, constant: leftConstant)
            constraint.identifier = "left"
            constraints.append(constraint)
        }
        
        if let bottom = bottom {
            let constraint = bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant)
            constraint.identifier = "bottom"
            constraints.append(constraint)
        }
        
        if let right = right {
            let constraint = rightAnchor.constraint(equalTo: right, constant: -rightConstant)
            constraint.identifier = "right"
            constraints.append(constraint)
        }
        
        if widthConstant > 0 {
            let constraint = widthAnchor.constraint(equalToConstant: widthConstant)
            constraint.identifier = "width"
            constraints.append(constraint)
        }
        
        if heightConstant > 0 {
            let constraint = heightAnchor.constraint(equalToConstant: heightConstant)
            constraint.identifier = "height"
            constraints.append(constraint)
        }
        
        constraints.forEach { $0.isActive = true }
        return constraints
    }
    
    func removeAllConstraints() {
        constraints.forEach { removeConstraint($0) }
    }
}

