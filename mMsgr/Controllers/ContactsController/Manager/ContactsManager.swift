//
//  ContactsManager.swift
//  mMsgr
//
//  Created by Aung Ko Min on 15/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import PhoneNumberKit
import Contacts
import Firebase

protocol ContactsManagerDelegate: class {
    func contactsManager(didChangeOperationsStatus status: String)
    func contactsManager(didFinishedCheckingStatus manager: ContactsManager)
}

final class ContactsManager: NSObject, AlertPresentable {
    
    private var hasSavedLocalContacts: Bool {
        get {
            return userDefaults.currentBoolObjectState(for: userDefaults.hasSavedPhoneContacts)
        }
        set {
            userDefaults.updateObject(for: userDefaults.hasSavedPhoneContacts, with: newValue)
        }
    }
    
    private var hasSyncContacts: Bool {
        get {
            return userDefaults.currentBoolObjectState(for: userDefaults.hasContactSynced)
        }
        set {
            userDefaults.updateObject(for: userDefaults.hasContactSynced, with: newValue)
        }
    }
    
    private var isTooEarlyToUpdateAgain: Bool {
        get {
            if let lastAccessedTimeStamp = userDefaults.currentIntObjectState(for: userDefaults.lastAccessedDate) {
                let date = Date.date(timestamp: Int64(lastAccessedTimeStamp))
                let diff = Date().timeIntervalSince(date)
                return diff < 3600
            }else {
                userDefaults.updateObject(for: userDefaults.lastAccessedDate, with: Date().timestamp())
                return false
            }
        }
        set {
            userDefaults.updateObject(for: userDefaults.lastAccessedDate, with: Date().timestamp())
        }
    }
    var shouldShowAlert = true
    
    // Check UserDefaults
    func checkStatus() {
        
        if !hasSavedLocalContacts {
            if shouldShowAlert {
                showAlertForContactsUse { agree in
                    if agree {
                        self.goSaveLocalContacts()
                    }
                }
            } else {
                goSaveLocalContacts()
            }
            
            return
        }
        
        if !hasSyncContacts {
            if shouldShowAlert {
                showAlertForRemoteSync { (agree) in
                    if agree {
                        self.goSyncContacts()
                    }
                }
            } else {
                goSyncContacts()
            }
            return
        }
        
        if !isTooEarlyToUpdateAgain {
            isTooEarlyToUpdateAgain = true
            forceSync()
            return
        }
        Async.main {
            self.delegate?.contactsManager(didFinishedCheckingStatus: self)
        }
        
    }
    
    // Force Sync
    func forceSync() {
        shouldShowAlert = false
        hasSavedLocalContacts = false
        hasSyncContacts = false
        checkStatus()
    }
    
    private lazy var localContactsFetcher: PhoneContactsFetcher = { [weak self] in
        $0.delegate = self
        return $0
        }(PhoneContactsFetcher())
    
    private lazy var queue: OperationQueue = OperationQueue()
    lazy var phoneNumberKit = PhoneNumberKit()
    weak var delegate: ContactsManagerDelegate?
}


extension ContactsManager: LocalContactsFetcherDelegate {
    // 1. Local Contacts
    private func goSaveLocalContacts() {
        localContactsFetcher.fetchContacts()
    }

    func fetchLocalContacts(didFinishFetchingDeviceContacts contacts: [CNContact]) {
        
        let models = contacts.map{ self.model(from: $0)}.compactMap{ $0 }
        let op = ContactsSaveOperation(models: models, delay: 0)
    
        op.completionBlock = {[unowned self, unowned op] in
            if op.isFinished {
                self.hasSavedLocalContacts = true
                self.checkStatus()
            }
        }
        queue.addOperation(op)
    }
    
    
    // 2. Sync Contacts
    private func goSyncContacts() {
        let friends = Friend.fetch(in: PersistenceManager.sharedInstance.viewContext, includePending: true, returnsObjectsAsFaults: false, predicate: Friend.predicate(forIsFriend: false), sortedWith: [NSSortDescriptor(key: "displayName", ascending: true)])
        let phoneNumbers = friends.map{ $0.phoneNumber }.compactMap{ $0 }
        
        searchModels(for: phoneNumbers)
    }
    
    func searchModels(for phoneNumbers: [String]) {
        var models = [FriendModel]()
        let querys = phoneNumbers.map{ Firestore.firestore().collection(MyApp.Users.rawValue).whereField("phoneNumber", isEqualTo: $0)}
        
        let group = DispatchGroup()
        
        for query in querys {
            group.enter()
            query.getModels(FriendModel.self) {(x, err) in
                if let err = err {
                    print(err)
                    group.leave()
                    return
                }
                if x != nil && (x?.count ?? 0) > 0 {
                    if let storeFriend = x?.first{
                        
                        models.append(storeFriend)
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            
            self.updateModels(toLocal: models)
        }
    }
    
    // 3
    func updateModels(toLocal models: [FriendModel]) {
        let op = ContactsSaveOperation(models: models, delay: 0)
        op.completionBlock = {[weak self] in
            guard let `self` = self else { return }
            self.hasSyncContacts = true
            self.isTooEarlyToUpdateAgain = true
            self.checkStatus()
            Async.main {
                self.delegate?.contactsManager(didChangeOperationsStatus: "\(Int(models.count)) contacts are updated")
            }
            
        }
        queue.addOperation(op)
    }
    
    // 4
    func fetchAllFromRemoteStore() {
        
        Firestore.firestore().collection(MyApp.Users.rawValue).getModels(FriendModel.self, completion: { [weak self] (storeFriends, error) in
            guard let `self` = self else { return }
            if let results = storeFriends {
                let op = ContactsSaveOperation(models: results, delay: 0)
                op.completionBlock = {[weak self] in
                    guard let `self` = self else { return }
                    Async.main {
                        self.delegate?.contactsManager(didFinishedCheckingStatus: self)
                    }
                }
                self.queue.addOperation(op)
            }
        })
    }
    func model(from contact: CNContact) -> FriendModel? {
        let phoneNumbers = contact.phoneNumbers.map{($0.value).value(forKey: "digits") as? String}.compactMap{ $0 }
        let mobiles = phoneNumberKit.parse(phoneNumbers).filter{ $0.type == .mobile}
        
        if let first = mobiles.first {
            let phoneNumberString = "+\(first.countryCode)\(first.nationalNumber)"
            var name: String
            if !contact.givenName.isWhitespace {
                name = contact.givenName.trimmed
            } else if !contact.nickname.isWhitespace {
                name = contact.nickname.trimmed
            } else if !contact.familyName.isWhitespace {
                name = contact.familyName.trimmed + " " + contact.middleName
            }else {
                name = phoneNumberString
            }
            return FriendModel(displayName: name, phoneNumber: phoneNumberString, pushId: phoneNumberString, uid: phoneNumberString, photoURL: nil)
        } else {
            return nil
        }
    }
    
    func contacts(handleAccessStatus: Bool) {
        if handleAccessStatus == false {
            showContactsAccessStatus()
        }
    }
}

//
extension ContactsManager {
    
    private func showAlertForContactsUse(_ completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Allow Access to Device's Contacts", message: "We need to access your device's contacts list. Your contacts will NOT be uploaded to our server and they will only be stored locally withing the application. Your contact list is needed in order to create mMsgr contacts list. For more informations about our Privacy Policy, you can go to app's Settings -> Privacy Policy or click 'View Privacy Policy' button below", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Agree and Continue", style: .default) { _ in
            completion(true)
        }
        let privacyAction = UIAlertAction(title: "View Privacy Policy", style: .default) { _ in
            guard let url = URL(string: "https://mmsgr-1b7a6.firebaseapp.com") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: { done in
                completion(done)
            })
        }
        alert.addAction(okAction)
        alert.addAction(privacyAction)
        alert.addCancelAction()
        alert.show()
    }
    
    private func showAlertForRemoteSync(_ completion: @escaping  (Bool) -> Void) {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Sync Contacts", font: UIFont.preferredFont(forTextStyle: .title3))
        alert.set(message: "Sync Contacts allows you to find users those are in your phone contacts and add them to mMsgr contact list automatically. We will use your address book phone numbers to search and save in mMsgr's device contacts list. We do NOT upload your phone contacts to our server or export to any places outside the application.", font: UIFont.preferredFont(forTextStyle: .footnote))
        
        alert.addAction(image: nil, title: "Continue", color: nil, style: .default, isEnabled: true) { done in
            completion(true)
        }
        
        alert.addAction(image: nil, title: "Read Privacy Policy", color: UIColor.myAppMint, style: .default, isEnabled: true) { _ in
            completion(false)
            AppUtility.gotoPrivacyPolicy()
        }
        
        alert.addCancelAction()
        alert.show()
    }
    
    private func showContactsAccessStatus() {
        self.AlertPresentable_showAlert(buttonText: "Go To Divice's Settings", message: "You have denied our request to access your phone contacts. Your contact list is needed in order to connect everyone in it. To allow access, please go to device's settings and turn on the contacts button.", cancelButton: true, style: .default) { ok in
            guard ok == true else { return }
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { done in
                    if done == true {
                        self.checkStatus()
                    }
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

