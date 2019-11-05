//
//  ChatBackgroundView.swift
//  mMsgr
//
//  Created by jonahaung on 17/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit


class BackgroundView: CustomView {
    
    override func setup() {
        super.setup()
        
        backgroundColor = UIColor.systemBackground
    }
    
    var step: Int = 50 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw( _ rect: CGRect) {
        
        let x = Int(bounds.origin.x)
        let y = Int(bounds.origin.y)
        let width = Int(bounds.width)
        let height = Int(bounds.height)
        
        for xvalue in stride(from: x, through: width, by: step) {
            for yvalue in stride(from: y, through: height, by: step) {
                drawLine(x: xvalue,y: yvalue, width: step, height: step)
            }
        }
    }
    
    func drawLine(x:Int, y:Int, width:Int, height:Int) {
        let leftToRight: Bool = Bool.random()
        
        let path = UIBezierPath()
        
        if(leftToRight) {
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + width, y: y + height))
        } else {
            path.move(to: CGPoint(x: x + width, y: y))
            path.addLine(to: CGPoint(x: x, y: y + height))
        }
        
        path.close()
        UIColor.secondarySystemBackground.set()
        path.stroke()
        path.fill()
    }
}
