//
//  MainTabBar+Setup.swift
//  mMsgr
//
//  Created by jonahaung on 2/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import SwiftUI

extension MainTabBarController {
    
    func configureNavigationItems() {
        
        let mmsgrItem = UIBarButtonItem(image: #imageLiteral(resourceName: "mMsgr-7").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(MainTabBarController.shareThisApp))
        mmsgrItem.imageInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        let badgeAvatarImageView = BadgeAvatarImageView()
        badgeAvatarImageView.padding = 1.5
        let showActiveStatus = userDefaults.currentBoolObjectState(for: userDefaults.showOnlineStatus)
        let color = showActiveStatus ? UIColor.systemGreen : UIColor.systemRed
        badgeAvatarImageView.badgeColor = color
        badgeAvatarImageView.backColor = color
        
        
        navigationItem.leftBarButtonItem = mmsgrItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: badgeAvatarImageView)
        
        badgeAvatarImageView.diameter = 35
        badgeAvatarImageView.loadImageForCurrentUser(refresh: false)
        
        badgeAvatarImageView.action { [weak self] x in
            self?.didChangeActiveStatus(x)
        }
    }
    
    @objc func didChangeActiveStatus(_ sender: BadgeAvatarImageView?) {
        
        let oldValue = userDefaults.currentBoolObjectState(for: userDefaults.showOnlineStatus)
        
        let buttonText = oldValue ? "Hide Active Status" : "Show Active Status"
        let message = oldValue ? "You have shared your online status" : "You have hidden your online status"
        self.AlertPresentable_showAlert(buttonText: buttonText, title: "Active Status", message: message, cancelButton: true, style: oldValue ? .destructive : .default) { yes in
            if yes {
                let newValue = !oldValue
                userDefaults.updateObject(for: userDefaults.showOnlineStatus, with: newValue)
                Async.main{
                    let color = newValue ? UIColor.systemGreen : UIColor.systemRed
                    sender?.badgeColor = color
                    sender?.backColor = color
                }
            }
        }
    }
    
    @objc private func shareThisApp() {
        AlertPresentable_showAlert(buttonText: "Share mMsgr", message: nil, cancelButton: true, style: .default) { agree in
            if agree == true {
                AppUtility.shareApp()
            }
        }
    }
    
    func setupTabs() {
        
        let inbox: InboxViewController = {
            $0.title = "Recents"
            $0.tabBarItem = UITabBarItem(tabBarSystemItem: .recents, tag: 0)
            return $0
        }(InboxViewController())
        let contact: ContactsViewController = {
            $0.title = "Contacts"
            $0.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 1)
            return $0
        }(ContactsViewController())
        
        let settings: AppViewController = {
            $0.title = "App"
            $0.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
            return $0
        }(AppViewController())
        
        viewControllers = [inbox, contact, settings]
        selectedIndex = 0
        navigationItem.title = "mMsgr"
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        navigationItem.title = viewController.title
        viewController.tabBarItem.badgeValue = nil
    }
}

