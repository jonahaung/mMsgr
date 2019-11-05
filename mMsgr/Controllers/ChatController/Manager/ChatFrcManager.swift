//
//  ChatFRC.swift
//  mMsgr
//
//  Created by Aung Ko Min on 22/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import CoreData
import UIKit

protocol ChatFrcManagerDelegate: class {
    func controllerDidChange(with updates: [ChatFrcManager.Update], completion: ((Bool) -> Void)?)
}
final class ChatFrcManager: NSObject {
    
    private let room: Room
    private let frc: NSFetchedResultsController<Message>
    typealias Update = (ChatCollectionView) -> Void
    private var updates = [Update]()
    weak var delegate: ChatFrcManagerDelegate?
    init(_room: Room) {
        room = _room
        let fetchRequest = NSFetchRequest<Message>(entityName: Message.entityName)
        fetchRequest.predicate = NSPredicate(format: "room == %@", _room)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.includesSubentities = false
        fetchRequest.includesPendingChanges = false
        fetchRequest.includesPropertyValues = false
//        fetchRequest.relationshipKeyPathsForPrefetching = ["sender"]
        fetchRequest.fetchBatchSize = GlobalVar.mMsgr_standDisplayLimit
        frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceManager.sharedInstance.viewContext, sectionNameKeyPath: "section", cacheName: nil)
        super.init()
        currentOffset = max(0, (totalMsgsCount - pageSize))
        
        fetch()
        
        
    }

    func fetch() {
        frc.delegate = nil
        frc.fetchRequest.fetchOffset = currentOffset
        do {
            try frc.performFetch()
            frc.delegate = self
        }catch {
            print(error.localizedDescription)
           
        }
    }
    
    private var currentOffset: Int = 0
    private let pageSize = GlobalVar.mMsgr_standDisplayLimit
    
    
    var hasMoreOldMessages: Bool {
        return currentOffset > 0
    }
    
    private var totalMsgsCount: Int {
        return Int(room.msgsCount)
    }
    
    var canPerformPagnition: Bool {
        return currentOffset != 0
    }
    
    func loadMoreOldMessages() -> Bool {
        currentOffset = max(0, currentOffset - pageSize)
        fetch()
        return hasMoreOldMessages
    }
    
    func object(at indexpath: IndexPath) -> Message {
        return frc.object(at: indexpath)
    }
    func section(at indexPath: IndexPath) -> NSFetchedResultsSectionInfo? {
        return frc.sections?[indexPath.section]
    }
    var sectionCount: Int {
        return frc.sections?.count ?? 0
    }
    func numberOfItems(in sectionIndex: Int) -> Int {
        return frc.sections?[sectionIndex].numberOfObjects ?? 0
    }
    deinit {
        updates.removeAll()
        print("DEINIT: ChatFrcManager")
    }
}



extension ChatFrcManager: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updates.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath  else { break }
            self.updates.append { x in
                x.insertItems(at: [newIndexPath])
            }
        case .update:
            guard let indexPath = indexPath else { break }
            self.updates.append { x in
                x.cellForItem(at: indexPath)?.reload()
            }
        case .move:
           
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { break }
            self.updates.append { x in
                x.moveItem(at: indexPath, to: newIndexPath)
            }
            
        case .delete:
            guard let indexPath = indexPath else { break }
            self.updates.append { x in
                x.deleteItems(at: [indexPath])
            }
            
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            self.updates.append { x in
                x.insertSections(IndexSet(integer: sectionIndex))
            }
        case .update:
//            self.updates.append { x in
//                x.reloadSections(IndexSet(integer: sectionIndex))
//            }
            break
        case .delete:
            self.updates.append { x in
                x.deleteSections(IndexSet(integer: sectionIndex))
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChange(with: self.updates, completion: { (done) in
            if done {
                self.updates.removeAll()
            }
        })
    }
    
}
