//
//  CALayer+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 2/3/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit


extension CAShapeLayer {
    
    
    static func circle(_ fillColor: UIColor, diameter: CGFloat) -> CAShapeLayer {
        
        let circle = CAShapeLayer()
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter * 2, height: diameter * 2))
        circle.frame = frame
        circle.path = UIBezierPath(ovalIn: frame).cgPath
        circle.fillColor = fillColor.cgColor
        
        return circle
    }
    
}


extension CALayer {
    
    func toImage() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        self.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
