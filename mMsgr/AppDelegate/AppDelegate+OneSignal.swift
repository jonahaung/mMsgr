//
//  AppDelegate+OneSignal.swift
//  mMsgr
//
//  Created by jonahaung on 17/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import OneSignal

extension AppDelegate: OSPermissionObserver, OSSubscriptionObserver {
    
    func setupOneSignal(launchOptions:  [UIApplication.LaunchOptionsKey: Any]?) {
        OneSignal.promptForPushNotifications { x in
            OneSignal.initWithLaunchOptions(launchOptions, appId: "67958cbc-4c25-4d91-ab5c-90fd442e56bc")
            OneSignal.inFocusDisplayType = .notification
            OneSignal.setLocationShared(false)
            OneSignal.add(self as OSPermissionObserver)
            OneSignal.add(self as OSSubscriptionObserver)
        }
    }

    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        if stateChanges.from.status == .notDetermined {
            if stateChanges.to.status == .authorized {
                
                if let pushId = GlobalVar.currentUser?.pushId {
                    GlobalVar.currentUser?.updatePushId(pushId: pushId)
                }
            } else if stateChanges.to.status == .denied {
                GlobalVar.currentUser?.updatePushId(pushId: "unregistered")
            }
        }
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
       
        if stateChanges.from.subscribed == false && stateChanges.to.subscribed == true {
            GlobalVar.currentUser?.updatePushId(pushId: stateChanges.to.userId)
        } else if stateChanges.from.subscribed == true && stateChanges.to.subscribed == false {
            GlobalVar.currentUser?.updatePushId(pushId: "unregistered")
        }
    }
}

