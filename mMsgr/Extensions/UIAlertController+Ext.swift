//
//  UIAlertController+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 29/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func addCancelAction(title: String = "Cancel", action: ((UIAlertAction)->Void)? = nil ) {

        addAction(image: nil, title: title, color: nil, style: .cancel, isEnabled: true, handler: action)
    }
}
