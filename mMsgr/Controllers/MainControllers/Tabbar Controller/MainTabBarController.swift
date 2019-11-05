//
//  MainTabBarController.swift
//  mMsgr
//
//  Created by jonahaung on 16/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController, MainCoordinatorDelegatee, AlertPresentable {

    var onceToken = 0
    

    lazy var splashContainer: SplashScreenContainer = { x in
        return x
    }(SplashScreenContainer(frame: UIScreen.main.bounds))
    
    weak var searchController: UISearchController?
    var isBiometricalAuthEnabled: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItems()
        tabBar.clipsToBounds = true
        setBarImage()
        configureSearchBar()
        setupTabs()
        delegate = self
        isBiometricalAuthEnabled = userDefaults.currentBoolObjectState(for: userDefaults.biometricalAuth)
        UNUserNotificationCenter.current().delegate = self
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if onceToken == 0 {
            onceToken = 1
            if isBiometricalAuthEnabled {
                if let window = AppDelegate.sharedInstance.window {
                    window.addSubview(splashContainer)
                    AppUtility.lockOrientation(.portrait)
                    DispatchQueueDelay(0.5) {[weak self] in
                        self?.splashContainer.authenticationWithTouchID()
                    }
                }
            }
        }else {
            GlobalVar.currentRoom = nil
            navigationController?.navigationBar.tintColor = nil
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            setBarImage()
        }
    }
    
    private func setBarImage() {
        let imageName = traitCollection.userInterfaceStyle == .dark ? "barDark" : "barLight"
        tabBar.backgroundImage = UIImage(named: imageName)
    }
    
    deinit {
        UNUserNotificationCenter.current().delegate = nil
        print("DEINIT: MainTabBarController")
    }
}


extension MainTabBarController : UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
        let content = notification.request.content
        
        let currentRoom = GlobalVar.currentRoom
        
        if let dic = content.userInfo["custom"] as? [String: Any],
            let data = dic["a"] as? NSDictionary,
            let roomId = data["roomId"] as? String, let room = Room.findOrFetch(in: PersistenceManager.sharedInstance.viewContext, predicate: Room.predicate(forID: roomId)) {
           
            let isFocusedUser = currentRoom == room
            
            if isFocusedUser, let chatView = chatViewController, chatView.collectionView.isCloseToBottom() {
                completionHandler([])
            } else {
                completionHandler([.alert])
            }
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notification = response.notification
        let content = notification.request.content
        
        let currentRoom = GlobalVar.currentRoom
        
        
        if let dic = content.userInfo["custom"] as? [String: Any],
            let data = dic["a"] as? NSDictionary,
            let roomId = data["roomId"] as? String, let room = Room.findOrFetch(in: PersistenceManager.sharedInstance.viewContext, predicate: Room.predicate(forID: roomId)) {

            let isFocusedUser = currentRoom == room

            if isFocusedUser {
                chatViewController?.collectionView.scrollToBottom(animated: true)
            } else {
               
                if currentRoom == nil {
                    self.gotoChatLogController(for: room)
                } else {
                   
                    navigationController?.popViewControler(animated: true, completion: {[weak self] in
                        guard let `self` = self else { return }
                        Async.main {
                            self.gotoChatLogController(for: room)
                        }
                    })
                }
            }
        }
    }
}
