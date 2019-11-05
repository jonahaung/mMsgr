//
//  VersionManager.swift
//  mMsgr
//
//  Created by Aung Ko Min on 4/6/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import FirebaseAuth

class VersionManager {
    
    class func checkVersion(user: User) -> Bool {
        
        guard let cString = Bundle.main.version else { return true }
        
        let appVersion = (cString as NSString).floatValue
        
        let storedVersion = VersionManager.storedVersion()

        if appVersion != storedVersion {
            
            VersionManager.updateVersion(to: appVersion)
            
            if storedVersion == 0.0 {
                userDefaults.resetToDefaults()
                StartUp.configureWelcomeMessate()
                StartUp.loadMyanmarLanguageData()
                return true
            }else if storedVersion < 6.9 {
                AppDelegate.sharedInstance.logout(user: GlobalVar.currentUser)
                return false
            }
            return true
        }
        return true
    }

    
    class func updateVersion(to currentVersion: Float) {
        userDefaults.updateObject(for: userDefaults.previousVersion, with: currentVersion.description)
    }
    
    class func storedVersion() -> Float {
        let storedVersion = userDefaults.currentStringObjectState(for: userDefaults.previousVersion) ?? "0"
        return (storedVersion as NSString).floatValue
    }
    
    
}
