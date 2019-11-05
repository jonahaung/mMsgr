//
//  Coordinator.swift
//  mMsgr
//
//  Created by jonahaung on 26/10/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

protocol Coordinator {
    
    var navigationController: NavigationController { get set }
    
    func pushViewController(_ viewController: UIViewController)
    
    func presentViewController(_ viewController: UIViewController)
    
    func gotoLoginController()
    
    func gotoTabbarController()
    
}
