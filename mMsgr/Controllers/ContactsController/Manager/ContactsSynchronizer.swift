//
//  ContactsSynchronizer.swift
//  mMsgr
//
//  Created by Aung Ko Min on 3/1/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Contacts
import PhoneNumberKit
import Firebase

class ContactsSynchronizeManager {

    static var shared: ContactsSynchronizer {
        print("ContactsSynchronizer shared")
        struct Singleton {
            static let instance = ContactsSynchronizer()
        }
        return Singleton.instance
    }

    let alertPresenter = AlertPresenter()
    let kid = PhoneNumberKit()

    // PRELOAD
    func syncContacts() {
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            retrieveContactsWithStore()
        } else {
            requestAccess()
        }
    }

    func requestAccess(){
        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: { [weak wSelf = self] (authorized, error) in
            if error != nil {
                wSelf?.alertPresenter.Ext_ConfirmActionSheetWithBlock(buttonText: "Goto Settings", title: "You have disabled access to use Phone's Contacts.", cancelButton: true, style: .default, completion: {
                    if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                        let presenter = AlertPresenter()
                        presenter.Ext_ConfirmActionSheetWithBlock(buttonText: "Sync", title: "Continue sync contacts?", cancelButton: true, style: .default, completion: {
                            ContactsSynchronizer.shared.syncContacts()
                        })
                    }
                })
            }
            if authorized {
                DispatchQueue.main.async {
                    wSelf?.alertPresenter.Ext_ConfirmActionSheetWithBlock(buttonText: "OK", title: "Access Granted.", cancelButton: false, style: .default, completion: nil)
                }
            }
        })
    }

    private func retrieveContactsWithStore() {
        let store = CNContactStore()
        var contacts = [CNContact]()
        Spinner.spin()
        do {
            let req = CNContactFetchRequest(keysToFetch: [ CNContactPhoneNumbersKey as CNKeyDescriptor ])
            try store.enumerateContacts(with: req) {  contact, stop in
                contacts.append(contact)
            }
            DispatchQueue.main.async { [weak self] in
                print(contacts.count)
                guard let sSelf = self else {
                    Spinner.stop()
                    return
                }
                var filtered = [String]()
                DispatchQueue.EXT_background(delay: 0, background: {
                    let valueStrings = contacts.map{ $0.phoneNumbers.map{ ($0.value).value(forKey: "digits") as! String } }
                    let numberStrings = valueStrings.flatMap{ $0 }

                    let mobiles = sSelf.kid.parse(numberStrings).filter{ $0.type == .mobile }
                    let phoneNumbers = mobiles.map{ "+" + $0.countryCode.description + $0.nationalNumber.description }
                    filtered = Array(Set(phoneNumbers))


                }, completion: {
                    print(filtered.count)
                    sSelf.searchAndSave(filtered)
                })
            }
        } catch {
            Spinner.stop()
            alertPresenter.Ext_ShowAlert(message: error.localizedDescription)
        }
    }


    // SYNC CONTACTS
    private func searchAndSave(_ phoneNumbers: [String]) {
        var founds = 0
        var saved = [String]()
        let api = AppDelegate().sharedInstance().chatAPI
        guard let currentUid = Auth.auth().currentUser?.uid else {
            Spinner.stop()
            return
        }
        DispatchQueue.EXT_background(delay: 3, background: {
            let firestore = Firestore.firestore()
            for phoneNumber in phoneNumbers {
//                if let model = FUser(phoneNumber, phoneNumber, phoneNumber, phoneNumber, phoneNumber, false, Date(), phoneNumber) {
//                    api?.friend_save(model, { x in
//                        print(x?.displayName)
//                    })
//                }
                firestore.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber).getModels(FirestoreFriend.self, completion: { (x, error) in
                    if let storeFriend = x?.first, storeFriend.uid != currentUser?.uid {
                        founds += 1
                        api?.friend_save(storeFriend, { friend in
                            if let name = friend?.displayName {
                                saved.append(name)
                            }
                        })
                    }
                })
            }
        }) { [weak self] in
            Spinner.stop()
            guard founds > 0 else {
                self?.alertPresenter.Ext_ShowAlert(message: "No Matching Contacts")
                return
            }

            let title = """

            Total \(founds) - matched contact(s) are found,
            \(founds - saved.count) - of them are extisting one(s) .. and
            \(saved.count) - new contact(s) are succefully saved..
            ........
            \(saved.joined(separator: "\n"))
            """

            self?.alertPresenter.Ext_ConfirmActionSheetWithBlock(buttonText: "OK", title: title)
        }
    }
}
