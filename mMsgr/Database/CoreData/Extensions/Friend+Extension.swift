//
//  Friend+Extension.swift
//  mMsgr
//
//  Created by Aung Ko Min on 19/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import Foundation
import CoreData
import FirebaseStorage
import PhoneNumberKit

let phoneNumberKit = PhoneNumberKit()

extension Friend: KeyCodeable {
    public enum Key: String {
        case uid, displayName, phoneNumber, lastAccessedDate, photoURL, pushId, state, messages, room, rooms
    }
}
extension Friend {
    
    @objc var isFriend: Bool {
        return uid != phoneNumber
    }
    
    @objc var firstCharacter: String {
        return displayName.firstCharacterAsString ?? "nil"
    }
    
    var photoURL_local: URL { return docURL.appendingPathComponent(uid) }
    var photoStorageReference: StorageReference { return  Storage.storage().reference().child("Profile Photo/\(uid).jpg") }

    var country: String? {
        if let number = phoneNumber, let prased = try? phoneNumberKit.parse(number), let country = phoneNumberKit.mainCountry(forCode: prased.countryCode){
            return Locale.current.localizedString(forRegionCode: country)
        }
        return nil
    }
    
    var roomId: String {
        let currentUserId = GlobalVar.currentUser?.uid ?? ""
        return uid <= currentUserId ? uid+currentUserId : currentUserId+uid
    }
    
    var hasBlocked: Bool {
        return state == 1
    }
    
    static func predicate(forUID uid: String) -> NSPredicate {
        return NSPredicate(format: "uid == %@", uid)
    }
    
    static func predicate(forDisplayName displayName: String) -> NSPredicate {
        return NSPredicate(format: "displayName ==[c] %@", displayName)
    }
    static func predicate(forIsFriend isFriend: Bool) -> NSPredicate {
        if isFriend {
            return NSPredicate(format: "uid != phoneNumber")
        } else {
            return NSPredicate(format: "uid == phoneNumber")
        }
        
    }
    static func predicate(forPhoneNumber phoneNumber: String) -> NSPredicate {
        return NSPredicate(format: "phoneNumber == %@", phoneNumber)
    }
    
    func merge(with model: FriendModel) {
        
        if uid != model.uid {
            uid = model.uid
        }
        if displayName != model.displayName {
            displayName = model.displayName
        }
        if phoneNumber != model.phoneNumber {
            phoneNumber = model.phoneNumber
        }
        if let urlStr = model.photoURL, let url = URL(string: urlStr), photoURL != url {
            photoURL = url
        }
        if pushId != model.pushId {
            pushId = model.pushId
        }
    }
    
    static func get(_ model: FriendModel, context: NSManagedObjectContext) -> Friend {
        if let existed = Friend.findOrFetch(in: context, predicate: Friend.predicate(forUID: model.uid)) {
            existed.merge(with: model)
            return existed
        }
        let x = Friend(context: context)
        x.uid = model.uid
        
        x.displayName = model.displayName
        x.phoneNumber = model.phoneNumber
        x.pushId = model.pushId
        if let urlStr = model.photoURL, let url = URL(string: urlStr) {
            x.photoURL = url
        }
        return x
    }
    
    func createAndLinkRoom() -> Room? {
        if let room = self.room {
            return room
        }else {
            let context = PersistenceManager.sharedInstance.editorContext
            if let friendLocal = try? context.localInstance(of: self) {
                let model = FriendModel(friend: friendLocal)
                let room = Room.get(model, context: context)
                friendLocal.room = room
                do {
                    try context.save()
                    return PersistenceManager.sharedInstance.viewContext.object(with: room.objectID) as? Room

                }catch {
                    print(error)

                }
            }
            return nil
        }
    }
    
}
