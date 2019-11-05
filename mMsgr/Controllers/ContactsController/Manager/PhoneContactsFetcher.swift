//
//  ContactsFetcher.swift
//  Pigeon-project
//
//  Created by Roman Mizin on 8/20/18.
//  Copyright © 2018 Roman Mizin. All rights reserved.
//

import UIKit
import Contacts


protocol LocalContactsFetcherDelegate: class {
    func fetchLocalContacts(didFinishFetchingDeviceContacts contacts: [CNContact])
    func contacts(handleAccessStatus: Bool)
}

class PhoneContactsFetcher: NSObject {
    
    weak var delegate: LocalContactsFetcherDelegate?
    
    func fetchContacts () {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        let store = CNContactStore()
        if status == .denied || status == .restricted {
            delegate?.contacts(handleAccessStatus: false)
            return
        }
        
        store.requestAccess(for: .contacts) { granted, error in
            guard granted, error == nil else {
                self.delegate?.contacts(handleAccessStatus: false)
                return
            }
            
            self.delegate?.contacts(handleAccessStatus: true)
            
            let keys = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactMiddleNameKey, CNContactNicknameKey]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            var contacts = [CNContact]()
            do {
                try store.enumerateContacts(with: request) { contact, stop in
                    contacts.append(contact)
                }
            } catch {}
            
            contacts = Array(Set(contacts))
            
            self.delegate?.fetchLocalContacts(didFinishFetchingDeviceContacts: contacts)
        }
    }
}
