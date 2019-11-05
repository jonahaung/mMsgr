//
//  Room+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 2/3/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import CoreData

extension Room: KeyCodeable {
    public enum Key: String {
        case id, isGroup, name, canTranslate, msgsCount, themeValue, unreadMessages
    }
}
extension Room {
    
    func getMediaFRC(type: MsgType) -> NSFetchedResultsController<Message> {
        let context = PersistenceManager.sharedInstance.viewContext
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [dateSort]
        let friendPredicate = NSPredicate(format: "room = %@", self)
        let mediaPredicate = NSPredicate(format: "msgType == \(type.rawValue)")
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [friendPredicate, mediaPredicate])
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil) as! NSFetchedResultsController<Message>
    }
    
    func getLastMessage() -> Message? {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        let predicate = NSPredicate(format: "room == %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = predicate
        request.fetchLimit = 1
        do{
            if let msg = try managedObjectContext?.fetch(request).first {
                return msg
            }
        }catch {
            Log(error.localizedDescription)
        }
        return nil
    }
    
    static func predicate(forID id: String) -> NSPredicate {
        return NSPredicate(format: "id == %@", id)
    }
    
    func merge(with model: RoomModel) {
        if name != model.name {
            name = model.name
        }
        if id != model.id {
            id = model.id
        }
    }
    
    func merge(with model: FriendModel) {
        if !isGroup {
            if name != model.displayName {
                name = model.displayName
            }
        }
    }
    
    static func get(_ model: RoomModel, context: NSManagedObjectContext) -> Room {
        if let existed = Room.findOrFetch(in: context, predicate: Room.predicate(forID: model.id)) {
            existed.merge(with: model)
            return existed
        }
        let x = Room(context: context)
        x.id = model.id
        x.name = model.name
        x.isGroup = model.isGroup
        return x
    }
    
    static func get(_ model: FriendModel, context: NSManagedObjectContext) -> Room {
        let roomId = Room.roomId(for: model)
        if let existed = Room.findOrFetch(in: context, predicate: Room.predicate(forID: roomId)) {
            existed.merge(with: model)
            return existed
        }
        let x = Room(context: context)
        x.id = roomId
        x.name = model.displayName
        x.isGroup = false
        return x
    }
    
    static func roomId(for fModel: FriendModel) -> String {
        let currentUserId = GlobalVar.currentUser?.uid ?? ""
        let fUID = fModel.uid
        return fUID <= currentUserId ? fUID+currentUserId : currentUserId+fUID
    }
}
