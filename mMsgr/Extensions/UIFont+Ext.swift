//
//  UIFont+Ext.swift
//  mMsgr
//
//  Created by jonahaung on 13/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit


public extension UIFont {
    
    static func taggedFont(for name: String, with size: CGFloat) -> UIFont {
        if let font = UIFont(name: name, size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    
    static func applyCurrentTraitsCollection() {
        
        UIFont.bodyFont = UIFontMetrics.default.scaledFont(for: UIFont.getBodyFont())
        UIFont.headlineFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 18, weight: .semibold))
        UIFont.bodyMyanmarFont = UIFontMetrics.default.scaledFont(for: UIFont(name: "NamKhoneWebPro", size: 17)!)
        UIFont.calloutFont = UIFont.preferredFont(forTextStyle: .callout).withTraits(.traitLooseLeading)!
    }
    
    
    
    static var myanmarFontSmaller = UIFontMetrics.default.scaledFont(for: UIFont(name: "NamKhoneWebPro", size: UIFont.systemFontSize)!)
    
    static var headlineFont = UIFont.systemFont(ofSize: 10)
    static var bodyFont = UIFont.systemFont(ofSize: 10)
    static var bodyMyanmarFont = UIFont.systemFont(ofSize: 10)
    static var calloutFont = UIFont.preferredFont(forTextStyle: .callout)
    
    static func getBodyFont() -> UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let fontDescriptor = defaultFontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits([.classModernSerifs, .traitUIOptimized]))

        let font: UIFont

        if let fontDescriptor = fontDescriptor {
            font = UIFont(descriptor: fontDescriptor, size: 17)
        } else {
            font = UIFont.bodyFont
        }

        return font
    }

    
    static var monoSpacedFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote)
        let fontDescriptor = defaultFontDescriptor.withSymbolicTraits(.traitMonoSpace)
        fontDescriptor?.withDesign(.monospaced)
        let font: UIFont

        if let fontDescriptor = fontDescriptor {
            font = UIFont(descriptor: fontDescriptor, size: 15)
        } else {
            font = UIFont.italicSystemFont(ofSize: 16)
        }

        return font
    }

}

extension UIFont {
    
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont? {
        
        if let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) {
            
            return UIFont(descriptor: descriptor, size: 17)
        }
        return nil
    }

    func bold() -> UIFont? {
        return withTraits(.traitBold)
    }

    func italic() -> UIFont? {
        return withTraits(.traitItalic)
    }

    func boldItalic() -> UIFont? {
        return withTraits(.traitBold, .traitItalic)
    }

    func semibold() -> UIFont? {
        return UIFont.systemFont(ofSize: self.pointSize, weight: .semibold)
    }

}
