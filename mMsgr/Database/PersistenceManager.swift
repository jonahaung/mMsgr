//
//  PersistenceManager.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//
import Foundation
import CoreData

final class PersistenceManager {
    
    class var sharedInstance: PersistenceManager {
        struct X {
            static let instance = PersistenceManager()
        }
        return X.instance
    }
    
    var stack: CoreDataStack!
    
    func loadStore(completion: @escaping () -> Void) {
        stack = CoreDataStack(storeType: NSSQLiteStoreType, callback: completion)
    }

    var viewContext: NSManagedObjectContext {
        stack.viewContext
    }
    
    lazy var editorContext: NSManagedObjectContext = {
        return $0
    }(stack.editorContext())
    
    lazy var importerContext: NSManagedObjectContext = {
        $0.undoManager = nil
        $0.shouldDeleteInaccessibleFaults = true
        $0.propagatesDeletesAtEndOfEvent = true
        return $0
    }(stack.importerContext())
}

extension NSManagedObjectContext {
    
    func saveIfHasChnages() {
        if hasChanges {
            do {
                try save()
                if let parent = self.parent {
                    parent.saveIfHasChnages()
                }
            }catch {
                print(error.localizedDescription)
            }
            
        }
    }
}

extension NSFetchedResultsController {
    
    @objc func validateIndexPath(_ indexPath: IndexPath) -> Bool {
        if let sections = self.sections, indexPath.section < sections.count {
            if indexPath.row < sections[indexPath.section].numberOfObjects {
                return true
            }
        }
        return false
    }
    
    @objc func lastIndexPath() -> IndexPath? {
        guard let sections = sections, sections.count > 0 else {
            return nil
        }
        let section = sections.count - 1
        let item = sections[section].numberOfObjects - 1
        guard item >= 0 else { return nil }
        let indexPath = IndexPath(item: item, section: section)
        if validateIndexPath(indexPath) {
            return indexPath
        }
        return nil
    }
    
    @objc static func clearCache(cacheName: String?) {
        NSFetchedResultsController.deleteCache(withName: cacheName)
    }
    
}
