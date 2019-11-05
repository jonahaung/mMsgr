//
//  AppDelegate+Firebase.swift
//  mMsgr
//
//  Created by jonahaung on 17/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

extension AppDelegate {
    
    func hasInstalledBefore() -> Bool {
        if let runCount = userDefaults.currentIntObjectState(for: userDefaults.runCountNamespace) {
            userDefaults.updateObject(for: userDefaults.runCountNamespace, with: runCount + 1)
            return true
        } else {
            userDefaults.updateObject(for: userDefaults.runCountNamespace, with: 1)
            return false
        }
    }
    

    // Login
    
    func login(user: User) {
        isOnline = true
        setOnlineStatus()
        
        mainCoordinator.gotoTabbarController()
    }
    
    // Logout
    
    func logout(user: User?){
        isOnline = false
        MessageSender.shared.stopObservingIncomingMessages()
        user?.updatePushId(pushId: "pushId")
        
        VersionManager.updateVersion(to: 0.0)
        
        do {
            try Auth.auth().signOut()
           self.mainCoordinator.gotoLoginController()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Online
    func setOnlineStatus()  {
        guard let user = Auth.auth().currentUser else { return }
        
        let database = Database.database()
        connectedRef = database.reference(withPath: ".info/connected")
        userRef =  database.reference().child("UserActivity").child(user.uid)
        onlineRef = userRef?.child("online")
        focusRef = userRef?.child(MyApp.Focused.rawValue)
        
        connectedRef?.observe(.value, with: { [weak self] (snapshot) in
            guard let sself = self, let connected = snapshot.value as? Bool else {
                self?.connected = false
                return
            }
            Async.main {
                sself.connected = connected
                sself.isOnline = connected
            }
            
        })
    }
}
