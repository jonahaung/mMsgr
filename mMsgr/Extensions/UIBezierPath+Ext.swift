//
//  UIBezierPath+Ext.swift
//  mMsgr
//
//  Created by jonahaung on 7/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

extension UIBezierPath {
    
    // swiftlint:disable:next function_body_length
//    static func roundedRectPath(basedOn rect: CGRect, cornerRadius: CGFloat, corners: UIRectCorner) -> UIBezierPath {
//        
//        let origin = rect.origin
//        let size = rect.size
//        
//        let point1 = CGPoint(x: origin.x + cornerRadius, y: origin.y)
//        let point2 = CGPoint(x: origin.x + size.width - cornerRadius, y: origin.y)
//        let point3 = CGPoint(x: origin.x + size.width, y: origin.y + cornerRadius)
//        let point4 = CGPoint(x: origin.x + size.width, y: origin.y + size.height - cornerRadius)
//        let point5 = CGPoint(x: origin.x + size.width - cornerRadius, y: origin.y + size.height)
//        let point6 = CGPoint(x: origin.x + cornerRadius, y: origin.y + size.height)
//        let point7 = CGPoint(x: origin.x, y: origin.y + size.height - cornerRadius)
//        let point8 = CGPoint(x: origin.x, y: origin.y + cornerRadius)
//        
//        let innerCenter23 = CGPoint(x: point2.x, y: point3.y)
//        let innerCenter45 = CGPoint(x: point5.x, y: point4.y)
//        let innerCenter67 = CGPoint(x: point6.x, y: point7.y)
//        let innerCenter81 = CGPoint(x: point1.x, y: point8.y)
//        
//        let outerCenter23 = CGPoint(x: point3.x, y: point2.y)
//        let outerCenter45 = CGPoint(x: point4.x, y: point5.y)
//        let outerCenter67 = CGPoint(x: point7.x, y: point6.y)
//        let outerCenter81 = CGPoint(x: point8.x, y: point1.y)
//        
//        let path = UIBezierPath()
//        path.move(to: point1)
//        path.addLine(to: point2)
//        if corners.contains(.topRight) || corners.contains(.allCorners) {
//            path.addArc(withCenter: innerCenter23, radius: cornerRadius, startAngle: -(.pi / 2), endAngle: 0, clockwise: true)
//        }
//        else {
//            path.addLine(to: outerCenter23)
//            path.addLine(to: point3)
//        }
//        path.addLine(to: point4)
//        if corners.contains(.bottomRight) || corners.contains(.allCorners) {
//            path.addArc(withCenter: innerCenter45, radius: cornerRadius, startAngle: 0, endAngle: -(3 * .pi / 2), clockwise: true)
//        }
//        else {
//            path.addLine(to: outerCenter45)
//            path.addLine(to: point5)
//        }
//        path.addLine(to: point6)
//        if corners.contains(.bottomLeft) || corners.contains(.allCorners) {
//            path.addArc(withCenter: innerCenter67, radius: cornerRadius, startAngle: -(3 * .pi / 2), endAngle: -(.pi), clockwise: true)
//        }
//        else {
//            path.addLine(to: outerCenter67)
//            path.addLine(to: point7)
//        }
//        path.addLine(to: point8)
//        if corners.contains(.topLeft) || corners.contains(.allCorners) {
//            path.addArc(withCenter: innerCenter81, radius: cornerRadius, startAngle: -(.pi), endAngle: -(.pi / 2), clockwise: true)
//        }
//        else {
//            path.addLine(to: outerCenter81)
//            path.addLine(to: point1)
//        }
//        return path
//    }
}
