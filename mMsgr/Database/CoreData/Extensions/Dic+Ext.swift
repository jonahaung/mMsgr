//
//  Dic+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 14/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import CoreData


extension Dic: KeyCodeable {
   
    public enum Key: String {
        case def, info, lastAccessedDate, length, rank, text, zawGyi
    }
}
extension Dic {
    
    static func completion(for word: String, in context: NSManagedObjectContext, isZawGyi: Bool) -> String? {
        let encoded = word.urlEncoded
        let encodedLength = encoded.utf16.count
        
        let request = NSFetchRequest<Dic>(entityName: "Dic")
        let fontType = isZawGyi ? Dic.Key.zawGyi.rawValue : Dic.Key.text.rawValue
        request.propertiesToFetch = [fontType]
        request.predicate = NSPredicate(format: "\(fontType) BEGINSWITH %@ && \(fontType) != %@", argumentArray: [encoded, encoded])
        request.sortDescriptors = [NSSortDescriptor(key: Dic.Key.lastAccessedDate.rawValue, ascending: false)]
        request.fetchLimit = 1
        do{
            if let found = try context.fetch(request).first, let encodedFoundText = isZawGyi ? found.zawGyi : found.text {
               
                return String(encodedFoundText.dropFirst(encodedLength)).urlDecoded
            }
        } catch {
            print(error.localizedDescription)
            
        }
        return nil
    }
    static func updateRank(for word: String, in context: NSManagedObjectContext) {
        let encoded = word.urlEncoded
        let context = PersistenceManager.sharedInstance.editorContext
        let request = NSFetchRequest<Dic>(entityName: "Dic")
        request.predicate = NSPredicate(format: "text == %@", encoded)
        request.fetchLimit = 1
        do{
            let dic = try context.fetch(request).first
            dic?.lastAccessedDate = Date()
            try context.save()
        } catch { print(error) }
        
    }
}
