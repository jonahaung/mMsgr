//
//  UserDefaults+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 19/3/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Foundation
import FirebaseDatabase

let userDefaults = UserDefaultsManager()

final class UserDefaultsManager: NSObject {
    
    fileprivate let defaults = UserDefaults.standard
    
    let authVerificationID = "authVerificationID"
    let phoneNumber = "phoneNumber"
    let changeNumberAuthVerificationID = "ChangeNumberAuthVerificationID"
    let hasRunBefore = "hasRunBefore"
    let biometricType = "biometricType"
    let biometricalAuth = "BiometricalAuth"
    let hasAgreeTerms = "hasAgreeTerms"
    let hasContactSynced = "hasContactSynced"
    let hasSavedPhoneContacts = "hasSavedPhoneContacts"
    
    let runCountNamespace = "runCountNamespace"
    let previousVersion = "previousVersion"
    let showOnlineStatus = "showOnlineStatus"
    let speakOutPannedMessages = "speakOutPannedMessages"
    let usesHighQualityTranslation = "usesHighQualityTranslation"
    let backgroundImageName = "backgroundImageName"
    let lastAccessedDate = "lastAccessedTime"
    let isZawgyiInstalled = "isZawgyiInstalled"
    //updating
    func updateObject(for key: String, with data: Any?) {
        
        
        switch key {
        case showOnlineStatus:
            if let bool = data as? Bool {
                if bool {
                    defaults.set(data, forKey: key)
                    defaults.synchronize()
                    AppDelegate.sharedInstance.isOnline = true
                } else {
                    AppDelegate.sharedInstance.isOnline = false
                    defaults.set(data, forKey: key)
                    defaults.synchronize()
                }
            }
        case usesHighQualityTranslation:
            if let bool = data as? Bool {
                MessageSender.shared.preferredHighQualityTranslation = bool
            }
            defaults.set(data, forKey: key)
            defaults.synchronize()
        default:
            defaults.set(data, forKey: key)
            defaults.synchronize()
        }
    }
    
    //removing
    func removeObject(for key: String) {
        defaults.removeObject(forKey: key)
    }
    
    
    func currentStringObjectState(for key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    func currentIntObjectState(for key: String) -> Int? {
        return defaults.integer(forKey: key)
    }
    
    func currentBoolObjectState(for key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
    
    func currentDoubleObject(for key: String) -> Double? {
        return defaults.double(forKey: key)
    }
    func currentFloatObject(for key: String) -> Float? {
        return defaults.float(forKey: key)
    }
    // other
    func configureInitialLaunch() {
        
        GlobalVar.isZawGyiPreferred = currentBoolObjectState(for: isZawgyiInstalled)
        
        if !currentBoolObjectState(for: hasRunBefore) {
            updateObject(for: hasRunBefore, with: true)
            resetToDefaults()
        }
    }
    
   
    func resetToDefaults() {
        updateObject(for: speakOutPannedMessages, with: true)
        updateObject(for: showOnlineStatus, with: true)
        updateObject(for: hasAgreeTerms, with: false)
        updateObject(for: biometricalAuth, with: false)
        updateObject(for: hasSavedPhoneContacts, with: false)
        updateObject(for: hasContactSynced, with: false)
        updateObject(for: hasAgreeTerms, with: false)
        updateObject(for: backgroundImageName, with: "BG-4")
        updateObject(for: isZawgyiInstalled, with: false)
        updateObject(for: usesHighQualityTranslation, with: false)
    }
}
