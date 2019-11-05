//
//  CGSize+Ext.swift
//  mMsgr
//
//  Created by jonahaung on 10/10/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

let UIMainScreenScale = UIScreen.main.scale

enum HorizontalAlignment {
    case left
    case center
    case right
}

enum VerticalAlignment {
    case top
    case center
    case bottom
}

extension CGSize {
    
    init(_ round: CGFloat) {
        self.init(width: round, height: round)
    }
    
    func bma_round(scale: CGFloat = UIMainScreenScale) -> CGSize {
        return CGSize(width: self.width.bma_round(scale: scale), height: self.height.bma_round(scale: scale))
    }
    
    func bma_rect(inContainer containerRect: CGRect, xAlignament: HorizontalAlignment, yAlignment: VerticalAlignment, dx: CGFloat = 0, dy: CGFloat = 0) -> CGRect {
        let originX, originY: CGFloat
        
        // Horizontal alignment
        switch xAlignament {
        case .left:
            originX = 0
        case .center:
            originX = containerRect.midX - self.width / 2.0
        case .right:
            originX = containerRect.maxX - self.width
        }
        
        // Vertical alignment
        switch yAlignment {
        case .top:
            originY = 0
        case .center:
            originY = containerRect.midY - self.height / 2.0
        case .bottom:
            originY = containerRect.maxY - self.height
        }
        
        return CGRect(origin: CGPoint(x: originX, y: originY).bma_offsetBy(dx: dx, dy: dy), size: self)
    }
    
    func rectCentered(at: CGPoint) -> CGRect{
        let dx = self.width/2
        let dy = self.height/2
        let origin = CGPoint(x: at.x - dx, y: at.y - dy )
        return CGRect(origin: origin, size: self)
    }
    
    func scaleBy(_ factor: CGFloat) -> CGSize{
        return CGSize(width: self.width*factor, height: self.height*factor)
    }
    var bounds: CGRect {
        return CGRect(origin: .zero, size: self)
    }
}

extension CGFloat {
    func bma_round(scale: CGFloat = UIMainScreenScale) -> CGFloat {
        return ceil(self * scale) * (1.0 / scale)
    }
}
extension CGPoint {
    
    func bma_offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}


extension CGRect{
    var center: CGPoint {
        return CGPoint( x: self.size.width/2.0, y: self.size.height/2.0)
    }
}

extension Double {
    
    var degrees: Double {
        return self * .pi / 180.0
    }
    
    var radians: Double {
        return self * 180.0 / .pi
    }
}
