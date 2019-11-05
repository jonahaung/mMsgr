//
//  UIEdgeInset+Ext.swift
//  mMsgr
//
//  Created by jonahaung on 19/9/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    internal var vertical: CGFloat {
        return top + bottom
    }
    
    internal var horizontal: CGFloat {
        return left + right
    }
    
}
