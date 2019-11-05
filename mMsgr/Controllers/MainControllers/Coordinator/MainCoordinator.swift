//
//  MainCoordinator.swift
//  mMsgr
//
//  Created by Aung Ko Min on 5/6/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit


final class MainCoordinator: Coordinator {
    
    internal var navigationController: NavigationController

    
    init(navigationController: NavigationController) {
        self.navigationController = navigationController
    }
    
    func pushViewController(_ viewController: UIViewController) {
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentViewController(_ viewController: UIViewController) {
        navigationController.present(viewController, animated: true, completion: nil)
    }
    
    func gotoLoginController() {
        navigationController.setViewControllers([LoginController()], animated: true)
    }
    
    func gotoTabbarController() {
        if navigationController.isNavigationBarHidden {
            navigationController.setNavigationBarHidden(false, animated: true)
        }
        
        if let user = GlobalVar.currentUser {
            
            if VersionManager.checkVersion(user: user) {
                MessageSender.shared.startObservingIncomingMessages(user: user)
                navigationController.setViewControllers([MainTabBarController()], animated: true)
            }
        }
    }
}
