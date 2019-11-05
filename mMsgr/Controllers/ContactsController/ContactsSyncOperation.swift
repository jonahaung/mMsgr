//
//  ContactsSyncOperation.swift
//  mMsgr
//
//  Created by Aung Ko Min on 22/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import CoreData
import FirebaseFirestore


// Downloads entries created after the specified date.
class ContactsSyncOperation: Operation {
    enum OperationError: Error {
        case cancelled
        case notFound
    }

    private let context: NSManagedObjectContext
    private let query: Query
    
    var result: Result<FriendModel, Error>?
    
    private var downloading = false
    private var currentDownloadTask: Void?
    
    init(context: NSManagedObjectContext, server: Query) {
        self.context = context
        self.query = server
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return downloading
    }
    
    override var isFinished: Bool {
        return result != nil
    }
    
    override func cancel() {
        super.cancel()
        if let currentDownloadTask = currentDownloadTask {
            currentDownloadTask
        }
    }
    
    func finish(result: Result<FriendModel, Error>) {
        guard downloading else { return }
        
        willChangeValue(forKey: #keyPath(isExecuting))
        willChangeValue(forKey: #keyPath(isFinished))
        
        downloading = false
        self.result = result
        currentDownloadTask = nil
        
        didChangeValue(forKey: #keyPath(isFinished))
        didChangeValue(forKey: #keyPath(isExecuting))
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        downloading = true
        didChangeValue(forKey: #keyPath(isExecuting))
        
        guard !isCancelled else {
            finish(result: .failure(OperationError.cancelled))
            return
        }
        
        currentDownloadTask = query.getModels(FriendModel.self) {[weak self] (x, err) in
            guard let `self` = self else { return }
            guard !self.isCancelled else {
                self.finish(result: .failure(OperationError.cancelled))
                return
            }
            
            if let err = err {
                self.finish(result: .failure(err))
            }else if x != nil && (x?.count ?? 0) > 0 {
                if let storeFriend = x?.first{
                    self.finish(result: .success(storeFriend))
                }else {
                    self.finish(result: .failure(OperationError.notFound))
                }
            } else {
                self.finish(result: .failure(OperationError.notFound))
            }
        }
        
    }

    
}

class ContactsSaveOperation: Operation {
    
    var models: [FriendModel]?
    var delay: TimeInterval = 0

    
    init(models: [FriendModel], delay: TimeInterval? = nil) {
        self.models = models.filter{ $0.uid != GlobalVar.currentUser?.uid ?? ""}
        if let delay = delay {
            self.delay = delay
        }
    }
    
    override func main() {
        
        guard let models = models else { return }
        PersistenceManager.sharedInstance.stack.shouldMergeIncomingSavedObjects = true
        let context = PersistenceManager.sharedInstance.importerContext
        context.perform {
            for model in models {
                let friend = Friend.get(model, context: context)
                let room = Room.get(model, context: context)
                
                if room.member != friend {
                    room.member = friend
                }

                if models.last == model {
                    context.saveIfHasChnages()
                     PersistenceManager.sharedInstance.stack.shouldMergeIncomingSavedObjects = false
                }
                if self.delay > 0 {
                    Thread.sleep(forTimeInterval: self.delay)
                }
                if self.isCancelled {
                    break
                }
            }
        }
    }
}
