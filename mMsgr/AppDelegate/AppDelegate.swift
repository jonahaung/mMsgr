
//  AppDelegate.swift
//  mMsgr
//
//  Created by Aung Ko Min on 30/7/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate  {

    static var sharedInstance: AppDelegate {
        struct Singleton {
            static let instance = UIApplication.shared.delegate as! AppDelegate
        }
        return Singleton.instance
    }
    internal let mainCoordinator = MainCoordinator(navigationController: NavigationController())
    
    var window: UIWindow?
    
    internal var userRef: DatabaseReference?
    internal var onlineRef: DatabaseReference?
    internal var focusRef: DatabaseReference?
    internal var connectedRef: DatabaseReference?

    var orientationLock = UIInterfaceOrientationMask.allButUpsideDown
    
    var connected: Bool = false {
        didSet {
            guard oldValue != connected else { return }

            AppUtility.showLoading(show: !connected)
            if connected {
                onlineRef?.onDisconnectSetValue(ServerValue.timestamp())
                focusRef?.onDisconnectRemoveValue()

                if let room = GlobalVar.currentRoom {

                    if let friend = room.member {
                        focusRef?.setValue(friend.uid)
                    }
                }
            }
        }
    }
    
    var isOnline: Bool = false {
        didSet {
            if oldValue != isOnline {
                if !connected {
                    isOnline = oldValue
                    return
                }
                let value: Any? = isOnline ? MyApp.online.rawValue : ServerValue.timestamp()
                onlineRef?.setValue(value)
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        ThemeManager.applyTheme()
        userDefaults.configureInitialLaunch()

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = self.mainCoordinator.navigationController
        self.window = window
        window.makeKeyAndVisible()
        
        PersistenceManager.sharedInstance.loadStore {
            
            
            let user = Auth.auth().currentUser
            if let loggedInUser = user, self.hasInstalledBefore() {
                self.login(user: loggedInUser)
            } else {
                self.logout(user: user)
            }
            
            
        }
        self.setupOneSignal(launchOptions: launchOptions)
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard Auth.auth().currentUser != nil else { return .portrait }
        return self.orientationLock
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        isOnline = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        isOnline = true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        userDefaults.updateObject(for: userDefaults.lastAccessedDate, with: Date().timestamp())
        isOnline = false
        
    }
   
    func applicationDidEnterBackground(_ application: UIApplication) {
        isOnline = false
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        isOnline = false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            print(incomingURL)
            return true
        }
        return false
    }
  
}
