//
//  User+Ext.swift
//  mMsgr
//
//  Created by jonahaung on 17/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import OneSignal

extension User {

    // Update
    func uploadToFirestore(completion: @escaping (Bool, Error?)-> Void) {
        guard let firestoreFriend = FriendModel(user: self)?.serialized as [String: AnyObject]? else {
            completion(false, nil)
            return
        }
        
        Firestore.firestore().collection(MyApp.Users.rawValue).document(uid).setData(firestoreFriend, merge: true) { err in
            if let err = err {
                completion(false, err)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func updatePushId(pushId: String?) {
        Firestore.firestore().collection(MyApp.Users.rawValue).document(uid).setData(["pushId": pushId as Any], merge: true)
        print("User updated PushID to \(pushId as Any)")
    }
    
    var isAdmin: Bool {
        return uid == "eQKVg0NSGgd8dljvGM0iDQfo1K43"
    }
    
    var pushId: String? {
        return OneSignal.getPermissionSubscriptionState()?.subscriptionStatus.userId
    }
    
}
extension User {
    
    var photoURL_local: URL {
        return docURL.appendingPathComponent(uid)
    }
    
    var avatar_storage_reference: StorageReference {
        return Storage.storage().reference().child("Profile Photo/\(uid).jpg")
    }
    
    func avatar_url_remote(completion: @escaping ((URL?, String?)) -> ()) {
        avatar_storage_reference.downloadURL { (url, err) in
            completion((url, err?.localizedDescription))
        }
    }
}

