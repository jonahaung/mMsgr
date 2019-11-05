//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import UIKit

//MARK: DefaultBubble class
/**
 Default bubble class is standard with our message configuration. It has three rounded corners and one square corner closest to the avatar.
 */
open class DefaultBubble: Bubble {
    
    //MARK: Public Variables
    
    /** Radius of the corners for the bubble. When this is set, you will need to call setNeedsLayout on your message for changes to take effect if the bubble has already been drawn*/
    open var radius : CGFloat = 16

    open fileprivate(set) var path: CGMutablePath = CGMutablePath()
    
    // MARK: Initialisers
    
    /**
     Initialiser class.
     */
    public override init() {
        super.init()
    }
    
    // MARK: Class methods
    
    /**
     Overriding sizeToBounds from super class
     -parameter bounds: The bounds of the content
     */
   open override func sizeToBounds(_ bounds: CGRect, _ bubbleType: BubbleType) {
        super.sizeToBounds(bounds, bubbleType)
        
        var rect = CGRect.zero
        var radius2: CGFloat = 0
        
       if bounds.width < 2*radius || bounds.height < 2*radius { //if the rect calculation yeilds a negative result
            let newRadiusW = bounds.width/2
            let newRadiusH = bounds.height/2
        
            let newRadius = newRadiusW>newRadiusH ? newRadiusH : newRadiusW
        
            rect = CGRect(x: newRadius, y: newRadius, width: bounds.width - 2*newRadius, height: bounds.height - 2*newRadius)
            radius2 = newRadius
        } else {
            rect = CGRect(x: radius, y: radius, width: bounds.width - 2*radius, height: bounds.height - 2*radius)
            radius2 = radius
        }
        
        path = CGMutablePath()
    
        path.addArc(center: CGPoint(x: rect.maxX, y: rect.minY), radius: radius2, startAngle: CGFloat(-Double.pi/2), endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX + radius2, y: rect.maxY + radius2))
        path.addArc(center: CGPoint(x: rect.minX, y: rect.maxY), radius: radius2, startAngle: CGFloat(Double.pi/2), endAngle: CGFloat(Double.pi), clockwise: false)
        path.addArc(center: CGPoint(x: rect.minX, y: rect.minY), radius: radius2, startAngle: CGFloat(Double.pi), endAngle: CGFloat(-Double.pi/2), clockwise: false)
    
        path.closeSubpath()
    }
    
    /**
     Overriding createLayer from super class
     */
    open override func createLayer() {
        super.createLayer()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.layer.path = path
      
        self.layer.position = CGPoint.zero
        
//        self.maskLayer.path = path
//        self.maskLayer.position = CGPoint.zero
        CATransaction.commit()
        
    }
}
