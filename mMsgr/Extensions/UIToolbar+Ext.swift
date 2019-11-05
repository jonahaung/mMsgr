//
//  UIToolbar+Ext.swift
//  mMsgr
//
//  Created by jonahaung on 18/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

extension UIToolbar {

    func cler() {
        self.backgroundColor = .clear
        self.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.setShadowImage(UIImage(), forToolbarPosition: .any)
        self.clipsToBounds = true

    }
}


extension UIBarButtonItem {
    
    static func space() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
}
