//
//  UIColor+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 2/3/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(_ R: CGFloat, _ G: CGFloat, _ B: CGFloat, _ A: CGFloat) {
        self.init(red: R / 255, green: G / 255, blue: B / 255, alpha: A)
    }
    
    
    static func randomColor() -> UIColor {
        let colors = avatarColors
        let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
        return colors[randomIndex]
    }
    
    func lighter(by percentage:CGFloat = 15.0) -> UIColor {
        return self.adjust(by: abs(percentage) ) ?? self
    }
    
    func darker(by percentage:CGFloat = 10.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) ) ?? self
    }
    
    func adjust(by percentage:CGFloat = 30.0) -> UIColor? {
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat = 0
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
    
    var isLight: Bool {
        var white: CGFloat = 0
        self.getWhite(&white, alpha: nil)
        return white > 0.5
    }
    
    func isBrightColor() -> Bool {
        guard let components = cgColor.components else { return false }
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return brightness < 0.5 ? false : true
    }
    
    static var avatarColors: [UIColor] = [UIColor.systemBlue, .myAppWatermelon, .myAppOrange, UIColor.systemTeal.darker(by: 13), .myappGreen, .myAppMint, .myAppGreenApple, .myAppPink, .myAppBlue, .systemRed, .systemPurple, .systemPink, .systemGreen, .myAppYellow, .myappGreen]

    static func forName(_ name: String) -> UIColor {
        return avatarColors[name.count % avatarColors.count]
    }
}
