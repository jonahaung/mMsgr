//
//  Date+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 17/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import Foundation
extension Date {
   
    static let shortRelativeDateFormatter: RelativeDateTimeFormatter = {
        $0.unitsStyle = .abbreviated
        $0.dateTimeStyle = .named
//        $0.formattingContext = .dynamic
        return $0
    }(RelativeDateTimeFormatter())
    
    static let fullRelativeDateFormatter: RelativeDateTimeFormatter = {
        $0.unitsStyle = .full
        return $0
    }(RelativeDateTimeFormatter())

    func timestampOfLastMessage() -> String {
        return Date.shortRelativeDateFormatter.localizedString(for: self, relativeTo: Date())
    }
    func forChatMessage() -> String {
        let seconds = Date().timeIntervalSince(self)

        if (seconds < 24 * 3600) {
            return  EXT_timeAgo()
        } else {
            return self.dateTimeString(ofStyle: .medium)
        }
    }
    
    func EXT_timeAgo() -> String {
        let date = self
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 1) {
            return "\(components.year!)y"
        } else if (components.month! >= 1) {
            return "\(components.month!)M"
        }else if (components.weekOfYear! >= 1) {
            return "\(components.weekOfYear!)w"
        }else if (components.day! >= 1) {
            return "\(components.day!)d"
        }else if (components.hour! >= 1) {
            return "\(components.hour!)h"
        }else if (components.minute! >= 1) {
            return "\(components.minute!)m"
        }else {
            return "<m"
        }
    }
    func EXT_timeAgoLong() -> String {
        let date = self
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 1) {
            return "\(components.year!)y ago"
        } else if (components.month! >= 1) {
            return "\(components.month!)M ago"
        }else if (components.weekOfYear! >= 1) {
            return "\(components.weekOfYear!)w ago"
        }else if (components.day! >= 1) {
            return "\(components.day!)d ago"
        }else if (components.hour! >= 1) {
            return "\(components.hour!)h ago"
        }else if (components.minute! >= 1) {
            return "\(components.minute!)m ago"
        }else {
            return "Just Now"
        }
    }
    
    

}

extension Date {
    
    func timestamp() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }

    static func date(timestamp: Int64) -> Date {
        let interval = TimeInterval(timestamp) / 1000
        return Date(timeIntervalSince1970: interval)
    }
}
