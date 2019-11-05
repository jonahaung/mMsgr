//
//  ShapeLayerView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 30/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

class ShapeLayerView: CustomView {
    
    override class var layerClass: AnyClass { return CAShapeLayer.self }
    var shapeLayer: CAShapeLayer { return layer as! CAShapeLayer }
    
    override func setup() {
        super.setup()
    }
    
    
    var path:UIBezierPath!
    
    override func draw(_ rect: CGRect) {
    
        path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft,.bottomRight], cornerRadii: CGSize(width: 15.0, height: 0.0))
    
        UIColor.orange.setFill()
        path.fill()
        UIColor.purple.setStroke()
        path.stroke()
      }
}
