//
//  UITableView+Ext.swift
//  mMsgr
//
//  Created by jonahaung on 15/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

extension UITableView {
    
    func isSafeToSelect(indexPath: IndexPath) -> Bool {
        deselectRow(at: indexPath, animated: false)
        if isEditing {
            isEditing = false
            return false
        }
        return true
    }
    
    func reloadData(_ completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion:{ _ in
            completion()
        })
    }
    
}
