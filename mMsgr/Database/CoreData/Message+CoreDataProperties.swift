//
//  Message+CoreDataProperties.swift
//  mMsgr
//
//  Created by Aung Ko Min on 14/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var date: Date
    @NSManaged public var hasRead: Bool
    @NSManaged public var id: UUID
    @NSManaged public var isSender: Bool
    @NSManaged public var language: String?
    @NSManaged public var language2: String?
    @NSManaged public var msgState: Int16
    @NSManaged public var msgType: Int16
    @NSManaged public var section: Int64
    @NSManaged public var text: String
    @NSManaged public var text2: String?
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var lastMsgPoiter: Room?
    @NSManaged public var room: Room?
    @NSManaged public var sender: Friend?

}
