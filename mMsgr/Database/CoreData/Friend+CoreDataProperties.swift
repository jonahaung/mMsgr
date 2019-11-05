//
//  Friend+CoreDataProperties.swift
//  mMsgr
//
//  Created by Aung Ko Min on 14/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//
//

import Foundation
import CoreData


extension Friend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Friend> {
        return NSFetchRequest<Friend>(entityName: "Friend")
    }

    @NSManaged public var displayName: String
    @NSManaged public var lastAccessedDate: Date?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var photoURL: URL?
    @NSManaged public var pushId: String?
    @NSManaged public var state: Int16
    @NSManaged public var uid: String
    @NSManaged public var messages: NSSet?
    @NSManaged public var room: Room?
    @NSManaged public var rooms: NSSet?

}

// MARK: Generated accessors for messages
extension Friend {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

// MARK: Generated accessors for rooms
extension Friend {

    @objc(addRoomsObject:)
    @NSManaged public func addToRooms(_ value: Room)

    @objc(removeRoomsObject:)
    @NSManaged public func removeFromRooms(_ value: Room)

    @objc(addRooms:)
    @NSManaged public func addToRooms(_ values: NSSet)

    @objc(removeRooms:)
    @NSManaged public func removeFromRooms(_ values: NSSet)

}
