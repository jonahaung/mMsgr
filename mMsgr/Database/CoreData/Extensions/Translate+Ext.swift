//
//  Translate+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 14/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import CoreData


extension Translate: KeyCodeable {
   
    public enum Key: String {
        case id, destination, source
    }
}
extension Translate {
    
    static func create(_ source: String, _ destination: String) {
        guard Translate.check(source: source, destination: destination) == false else { return }
        let context = PersistenceManager.sharedInstance.editorContext
        context.perform {
            let obj = Translate(context: context)
            obj.id = UUID()
            obj.source = source
            obj.destination = destination
            context.save(shouldPropagate: true) { err in
                if let err = err { print(err)}
            }
        }
        
    
    }
    
    static func check(source: String, destination: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Translate.entityName)
        request.predicate = NSPredicate(format: "source ==[c] %@ OR destination ==[c] %@", argumentArray: [source, destination])
        request.resultType = .countResultType
        request.fetchLimit = 1
        do{
            let count = try request.execute().count
            return count == 0 ? false : true
        } catch {print(error)}
        return false
    }
    
    static func fetch(source: String, in context: NSManagedObjectContext) -> Translate? {
        return Translate.findOrFetch(in: context, predicate: NSPredicate(format: "source == %@", source))
    }
}
