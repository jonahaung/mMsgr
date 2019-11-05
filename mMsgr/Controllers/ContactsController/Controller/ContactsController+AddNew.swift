//
//  ContactsController+AddNew.swift
//  mMsgr
//
//  Created by Aung Ko Min on 18/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import FirebaseFirestore
import PhoneNumberKit

extension ContactsViewController {
    
    @objc func didTapAddContacts() {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Add/Search Contacts", font: UIFont.preferredFont(forTextStyle: .title3))
        
        alert.addAction(title: "Automatically Search from Contacts") { _ in
            self.syncContacts()
        }
        
        if GlobalVar.currentUser?.isAdmin == true {
            alert.addAction(title: "Fetch All Contacts") { [weak self] _ in
                guard let `self` = self else { return }
                self.contactManager.fetchAllFromRemoteStore()
            }
        }
        
        alert.addAction(title: "Find from Device's Contacts") { [weak self] _ in
            guard let `self` = self else { return }
            let x = UIAlertController(style: .actionSheet)
            x.addContactsPicker {  [weak self] (contact) in
                guard let `self` = self else { return }
                if let contact = contact {
                    contact.phones.forEach{ self.search(numberString: $0.number )}
                    
                }
            }
            x.addCancelAction(title: "Cancel") { [weak self] _ in
                guard let `self` = self else { return }
                self.didTapAddContacts()
            }
            x.show()
        }
        
        alert.addAction(title: "Enter Phone Number Manually") { [weak self] _ in
            guard let `self` = self else { return }
            self.enterNumber()
        }
        
        alert.addCancelAction()
        
        alert.show()
    }
    
    
    private func enterNumber() {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Phone Number", font: UIFont.preferredFont(forTextStyle: .title3))
        alert.set(message: "Please enter a valid mobile phone number without region code", font: UIFont.preferredFont(forTextStyle: .callout))
        var phoneNumber: String?
        
        let textField: TextField.Config = { textField in
            textField.keyboardType = .phonePad
            textField.placeholder = "Mobile Phone Number"
            textField.returnKeyType = .done
            textField.textContentType = .telephoneNumber
            textField.action { textField in
                if let text = textField.text {
                    phoneNumber = text
                }
            }
        }
        
        alert.addOneTextField(configuration: textField)
        
        alert.addAction(image: nil, title: "Search", color: nil, style: .default, isEnabled: true, handler: { [weak self] _ in
            guard let `self` = self else { return }
            if let number = phoneNumber {
                
                self.search(numberString: number)
            }
        })
        alert.addCancelAction { _ in
            self.didTapAddContacts()
        }
        alert.show()
    }
    
    private func search(numberString: String) {
        guard let phoneNumber = try? self.contactManager.phoneNumberKit.parse(numberString.withoutSpacesAndNewLines.trimmed) else {
            self.AlertPresentable_showAlertSimple(message: "Incorrect Phone Number")
            return
        }
        
        guard phoneNumber.type == .mobile else {
            self.AlertPresentable_showAlertSimple(message: "Incorrect Mobile Phone Number")
            return
        }
        
        
        let numberString = "+\(phoneNumber.countryCode)\(phoneNumber.nationalNumber)"
        if let friend = Friend.findOrFetch(in: PersistenceManager.sharedInstance.viewContext, predicate: Friend.predicate(forPhoneNumber: numberString)), friend.isFriend {
            self.AlertPresentable_showAlertSimple(message: "This number has already saved in Contacts List")
            return
        }
        
        
        Firestore.firestore().collection(MyApp.Users.rawValue).whereField("phoneNumber", isEqualTo: numberString).getModels(FriendModel.self) { (model, err) in
            if let err = err {
                print(err)
            }else if let md = model?.first {
                Async.main {
                    self.comfirmToSave(model: md)
                }
            }else {
                self.AlertPresentable_showAlertSimple(message: "This phone number is not registered at mMsgr")
            }
        }
    }
    
    private func comfirmToSave(model: FriendModel) {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: model.displayName, font: UIFont.preferredFont(forTextStyle: .title2))
        alert.set(message: model.phoneNumber ?? "No Phone Number", font: UIFont.preferredFont(forTextStyle: .body))
        alert.addAction(title: "Save to Contacts") {  [weak self] _ in
            guard let `self` = self else { return }
            self.contactManager.updateModels(toLocal: [model])
        }
        alert.addCancelAction()
        alert.show()
        
    }
}
