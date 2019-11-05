//
//  ActivityObserver.swift
//  mMsgr
//
//  Created by jonahaung on 10/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

struct UserActivity {
    
    var isOnline: Bool
    var isFocused: Bool
    var lastSeenDate: Date
    var isTyping: Bool
    
    init(dic: NSDictionary) {
        
        let uid = GlobalVar.currentUser?.uid
        
        let onlineValue = dic["online"]
        
        let isOnline = onlineValue is String
        let isFocused = (dic[MyApp.Focused.rawValue] as? String) == uid
        
        
        self.isOnline = isOnline
        self.isFocused = isFocused
        
        if let number = onlineValue as? Int64 {
            self.lastSeenDate = Date.date(timestamp: number)
        } else {
            self.lastSeenDate = Date()
        }
        if isOnline && isFocused {
            self.isTyping = (dic[MyApp.typing.rawValue] as? String) == uid
        } else {
            self.isTyping = false
        }
    }
}


protocol ActivityObserverDelegate: class {
    func activityObserver(_ observer: ActivityObserver, didGetLastReadDate date: NSDate)
    func activityObserver(_ observer: ActivityObserver, updateFriendwith firestoreFriend: FriendModel)
    func activityObserver_didChangeActivity(activity: UserActivity?)
}

final class ActivityObserver {
    
    weak var delegate: ActivityObserverDelegate?
    
    private var hasReadListener: ListenerRegistration?
    private var incomingHasRefColRef: DocumentReference?
    private var outgoingHasRefColRef: DocumentReference?
    private var incomingUserDocRef: DocumentReference?
    private var myRef: DatabaseReference?
    private var hisRef: DatabaseReference?
    private var onlineStatusTag: UInt?
    private let friendId: String
    private var canShowOnlineStatus: Bool = false
    private var isOutgoingIsTyping = false
    private var isFocusing = false
    private var isObserving = false
    
    var activity: UserActivity? {
        didSet {
            delegate?.activityObserver_didChangeActivity(activity: activity)
        }
    }
    
    var lastReadDateTime: NSDate? {
        didSet {
            if oldValue != lastReadDateTime {
                if let date = lastReadDateTime {
                    incomingHasRefColRef?.updateData([MyApp.HasRead.rawValue: NSNull()])
                    delegate?.activityObserver(self, didGetLastReadDate: date)
                }
                
            }
        }
    }
    
    
    
    init?(room: Room?) {
        guard let user = Auth.auth().currentUser, let friend = room?.member else { return nil }
        canShowOnlineStatus =  userDefaults.currentBoolObjectState(for: userDefaults.showOnlineStatus)
        self.friendId = friend.uid
        let userCollectionRef = Firestore.firestore().collection(MyApp.Users.rawValue)
        let userDatabaseRef = Database.database().reference().child("UserActivity")
        
        incomingUserDocRef = userCollectionRef.document(friendId)
        incomingHasRefColRef = incomingUserDocRef?.collection(MyApp.friends.rawValue).document(user.uid)
        outgoingHasRefColRef = userCollectionRef.document(user.uid).collection(MyApp.friends.rawValue).document(friendId)
        myRef = userDatabaseRef.child(user.uid)
        hisRef = userDatabaseRef.child(friendId)
    }
    
    deinit {
        stop()
        print("DEINIT: ActivityObsercer")
        
    }
    
}

// Outgoing

extension ActivityObserver {
    
    func setHasReadToLastMsg() {
        let data = [MyApp.HasRead.rawValue: FieldValue.serverTimestamp()]
        outgoingHasRefColRef?.setData(data, merge: false)
    }
    
    
    
    func setTyping(isTyping: Bool) {
        guard self.canShowOnlineStatus && activity?.isOnline == true && activity?.isFocused == true && isOutgoingIsTyping != isTyping else { return }
        let typingRef = myRef?.child(MyApp.typing.rawValue)
        isTyping ? typingRef?.setValue(friendId) : typingRef?.removeValue()
        isOutgoingIsTyping = isTyping
       print("set typing")
    }
    
}

// Incoming

extension ActivityObserver {
    
    private func setFocus(isFocused: Bool) {
        guard self.canShowOnlineStatus && activity?.isOnline == true && isFocused != self.isFocusing else { return }
        let focusedRef = myRef?.child(MyApp.Focused.rawValue)
        isFocused ? focusedRef?.setValue(friendId) : focusedRef?.removeValue()
        self.isFocusing = isFocused
       print("setFocus")
    }
    
    private func getFriendData() {
        incomingUserDocRef?.getModel(FriendModel.self, completion: { [weak self] (storeFriend, error) in
            guard let `self` = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let storeFriend = storeFriend {
                self.delegate?.activityObserver(self, updateFriendwith: storeFriend)
            }
        })
    }
    
    
    private func observeOnlineStatus() {
        onlineStatusTag = hisRef?.observe(.value, with: { [weak self] (snapshot) in
            guard let `self` = self, snapshot.exists() else { return }
            if let dic = snapshot.value as? NSDictionary {
                self.activity = UserActivity(dic: dic)
                if self.activity?.isOnline == true {
                    self.setFocus(isFocused: true)
                }else {
                    self.setFocus(isFocused: false)
                }
            } else {
                self.activity = nil
            }
        })
        
    }
    
    private func observeHasRead() {
        hasReadListener =  incomingHasRefColRef?.addSnapshotListener({ [weak self] (snap, err) in
            guard let `self` = self else { return }
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard snap?.exists == true, let data = snap?.data() else { return}
            if let timeStamp =  data[MyApp.HasRead.rawValue] as? Timestamp {
                self.lastReadDateTime = timeStamp.dateValue() as NSDate
                self.incomingUserDocRef?.collection(MyApp.HasRead.rawValue).document().delete()
            }
        })
    }
    
    private func stop() {
        guard isObserving else { return }
        isObserving = false
        
        setTyping(isTyping: false)
        setFocus(isFocused: false)
        hasReadListener?.remove()
        if let tag = onlineStatusTag {
            myRef?.removeObserver(withHandle: tag)
        }
    }
    
    func start() {
        if !isObserving && canShowOnlineStatus {
            isObserving = true
            observeOnlineStatus()
            observeHasRead()
            getFriendData()
            setHasReadToLastMsg()
        }
        
    }
}
