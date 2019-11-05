//
//  ChatCollectionViewManager.swift
//  mMsgr
//
//  Created by Aung Ko Min on 4/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import CoreData

protocol ChatManagerDelegate: class {
    func chatManager(scrollToBottom manager: ChatManager)
    func chatManager(_ manager: ChatManager, shouldUpdateTime time: String?)
    func chatManager(_ manager: ChatManager, scrollViewIsScrolling isScrolling: Bool)
    func chatManager(_ manager: ChatManager, didUpdateUserActivity activity: UserActivity)
    func chatManager(_ manager: ChatManager, didUpdateFriendURL urlString: String?)
}

final class ChatManager {
    
    internal let room: Room
    
    private let chatCollectionViewDatasource = ChatCollectionViewDatasource()
    private let chatCollectionViewDelegate = ChatCollectionViewDelegate()
    internal let chatFrcManager: ChatFrcManager
    internal let collectionView: ChatCollectionView
    
    private lazy var activityObserver = ActivityObserver(room: room)
    var isCollectionViewIsScrolling = false
   
    weak var delegate: ChatManagerDelegate?
    private var isFirstTimeLoading = true
    private var cachedScrollPercentage = CGFloat(0)
    private var isPaganating = false
    let queue: OperationQueue = {
        $0.qualityOfService = .background
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())
    
    init(_room: Room, _collectionView: ChatCollectionView) {
        room = _room
        collectionView = _collectionView
        
        chatFrcManager = ChatFrcManager(_room: _room)
        _collectionView.delegate = chatCollectionViewDelegate
        _collectionView.dataSource = chatCollectionViewDatasource
    
        chatFrcManager.delegate = self
        chatCollectionViewDelegate.delegate = self
        chatCollectionViewDatasource.delegate = self
        
        let collectionViewLayout = _collectionView.collectionViewLayout as? ChatCollectionViewLayout
        collectionViewLayout?.layoutDelegate = self
        
    }
    
    deinit {
        queue.cancelAllOperations()
        print("DEINIT: ChatManager")
    }
}

extension ChatManager: ChatFrcManagerDelegate {
    
    func controllerDidChange(with updates: [ChatFrcManager.Update], completion: ((Bool) -> Void)?) {
        queue.isSuspended = true
        collectionView.performBatchUpdates({[weak self] in
            guard let `self` = self else { return }
            updates.forEach{ $0(self.collectionView)}
            }, completion: { done in
                self.queue.isSuspended = false
                completion?(done)
            }
        )
    }
}

extension ChatManager {
    
    func viewDid(appear: Bool) {
        if appear {
            if isFirstTimeLoading {
                isFirstTimeLoading = false
                activityObserver?.delegate = self
                activityObserver?.start()
                queue.addOperation {[weak self] in
                    guard let `self` = self else { return }
                    self.handleIncomingUnreadMessages()
                }
                queue.addOperation {[weak self] in
                    guard let `self` = self else { return }
                    self.room_resetSectionDate()
                }
            }
        } else {
            queue.cancelAllOperations()
        }
    }
    
    func setTyping(isTyping: Bool) {
        activityObserver?.setTyping(isTyping: isTyping)
    }
}


// Layout Delegate

extension ChatManager: ChatCollectionViewLayoutDelegate {
    
    func finalizeCollectionViewUpdates(hasInserted: Bool) {
        
        if hasInserted {
            if collectionView.isCloseToBottom() {
                isCollectionViewIsScrolling = false
                delegate?.chatManager(scrollToBottom: self)
            }
            if let msg = room.lastMsg, !msg.isSender && !msg.hasRead {
                activityObserver?.setHasReadToLastMsg()
                handleIncomingUnreadMessages()
            }
        }
    }
}

// Datasource

extension ChatManager: ChatCollectionViewDatasourceDelegate {
   
    var sectionCount: Int {
        return chatFrcManager.sectionCount
    }
    
    func numberOfItems(in section: Int) -> Int {
        return chatFrcManager.numberOfItems(in: section)
    }
    
    func msg(at indexPath: IndexPath) -> Message {
        return chatFrcManager.object(at: indexPath)
    }
}

// Delegate

extension ChatManager: ChatCollectionViewDelegateProtocol {
    
    var hasMoreOldMessages: Bool {
        chatFrcManager.hasMoreOldMessages
    }
    
    
    func chatDatasource_didUpdate(timeString text: String?) {
        delegate?.chatManager(self, shouldUpdateTime: text)
    }
    
    func scrollViewInteracting(isScrolling: Bool) {
        delegate?.chatManager(self, scrollViewIsScrolling: isScrolling)
        if !isScrolling {
            loadOnScreenCells()
        }
    }
    
    func chatDatasource_isCollectionViewIsFinishedScrolling() {
        isCollectionViewIsScrolling = false
    }
    
    func autoLoadMoreContentIfNeeded() {
        guard !isPaganating else { return }
        let currentScrollPercentage = (collectionView.contentOffset.y / collectionView.contentSize.height)
        
        guard cachedScrollPercentage != currentScrollPercentage else { return }
        
        let isScrollingUp = cachedScrollPercentage > currentScrollPercentage
        
        cachedScrollPercentage = currentScrollPercentage
        
        if isScrollingUp {
            let isAtTop = currentScrollPercentage < 0.0001
            
            if chatFrcManager.hasMoreOldMessages && isAtTop {
                loadMoreOldMessages()
            }
        }
    }
    
    private func loadMoreOldMessages() {
        isPaganating = true

        let hasSomeMoreToLoad = chatFrcManager.loadMoreOldMessages()
        
        let old = collectionView.contentSize
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        let new = collectionView.contentSize
        
        let newOffset = CGPoint(x: collectionView.contentOffset.x + (new.width - old.width), y: collectionView.contentOffset.y + (new.height - old.height))
    
        collectionView.contentOffset.y = newOffset.y

        if hasSomeMoreToLoad == true {
            self.isPaganating = false
        }
        
    }
    
    private func loadOnScreenCells() {
        if let cells = collectionView.visibleCells as? [MessageCell] {
            cells.forEach{ $0.appearingOnScreen() }
        }
    }
}


// ActivityObserver

extension ChatManager: ActivityObserverDelegate {
    
    
    
    func activityObserver(_ observer: ActivityObserver, updateFriendwith firestoreFriend: FriendModel) {
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            let context = PersistenceManager.sharedInstance.editorContext
            guard let room = context.object(with: self.room.objectID) as? Room, let friend = room.member else { return }
            let oldURL = friend.photoURL?.absoluteString
            
            friend.merge(with: firestoreFriend)
            
            context.saveIfHasChnages()
        
            if oldURL != firestoreFriend.photoURL {
                OperationQueue.main.addOperation {
                    self.delegate?.chatManager(self, didUpdateFriendURL: firestoreFriend.photoURL)
                }
            }
            
        }
    }
    
    func activityObserver_didChangeActivity(activity: UserActivity?) {
        guard let activity = activity else { return }
        DispatchQueue.main.async {
            self.delegate?.chatManager(self, didUpdateUserActivity: activity)
        }
    }
}

// Others

extension ChatManager {
    
    func activityObserver(_ observer: ActivityObserver, didGetLastReadDate date: NSDate) {
        
        queue.addOperation {[weak self] in
            guard let `self` = self else { return }
            guard let roomId = self.room.id else { return }
            let context = PersistenceManager.sharedInstance.editorContext
            let predicate = NSPredicate(format: "room.id == %@ && hasRead == FALSE && isSender == TRUE && date < %@", argumentArray: [roomId, date])
            let msgs = Message.fetch(in: context, includePending: false, returnsObjectsAsFaults: false, predicate: predicate, sortedWith: nil)
            msgs.forEach{ $0.hasRead = true }
            context.saveIfHasChnages()
        }
        
    }
    private func handleIncomingUnreadMessages() {
        guard let roomId = self.room.id else { return }
        let context = PersistenceManager.sharedInstance.editorContext
        let predicate = NSPredicate(format: "room.id == %@ && hasRead == FALSE && isSender == FALSE", roomId)
        let msgs = Message.fetch(in: context, includePending: false, returnsObjectsAsFaults: false, predicate: predicate, sortedWith: nil)
        msgs.forEach{ $0.hasRead = true }
        context.saveIfHasChnages()
    }
    
    private func room_resetSectionDate() {
        guard let roomId = self.room.id else { return }
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "room.id == %@", roomId)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let context = PersistenceManager.sharedInstance.editorContext
        do {
            let msgs = try context.fetch(request)
            
            msgs.forEach { msg in
                let before = msgs.before(msg)
                let section = msg.getSectionDate(for: before)
                if msg.section != section {
                    msg.section = section
                }
            }
           
            context.saveIfHasChnages()
        }catch { print(error)}
        
    }
}
