//
//  FirestoreFriend.swift
//  mMsgr
//
//  Created by jonahaung on 6/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//
import Foundation
import Firebase

struct FriendModel: Codable, Hashable {

    let displayName: String
    let phoneNumber: String?
    let pushId: String?
    let uid: String
    let photoURL: String?
}

extension FriendModel: FirestoreModel {
    
    init?(modelData: FirestoreModelData) {
        self.init(dic: modelData.data)
    }
    
    init?(user: User) {
        self.init(displayName: user.displayName ?? "Display Name", phoneNumber: user.phoneNumber ?? "Phone Number", pushId: user.pushId ?? "Push ID", uid: user.uid, photoURL: user.photoURL?.absoluteString ?? "url")
    }
    
    init?(dic: [String: Any]?) {
        guard
            let dic = dic,
            let uid = dic[MyApp.uid.rawValue] as? String,
            let displayName = dic[MyApp.displayName.rawValue] as? String,
            let phoneNumber = dic[MyApp.phoneNumber.rawValue] as? String
            else { return nil }
        
        let pushId = dic[MyApp.pushId.rawValue] as? String ?? ""
        let photoURLString = dic["photoURL"] as? String
        self.init(displayName: displayName, phoneNumber: phoneNumber, pushId: pushId, uid: uid, photoURL: photoURLString)
    }
    
    init(friend: Friend) {
        self.init(displayName: friend.displayName, phoneNumber: friend.phoneNumber, pushId: friend.pushId, uid: friend.uid, photoURL: friend.photoURL?.absoluteString)
    }
}
