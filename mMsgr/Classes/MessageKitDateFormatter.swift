//
//  MessageDateFormatter.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//
import Foundation

open class MessageDateFormatter {

    // MARK: - Properties
    private var cache = [Date: String]()
    private var timeAgoCache = [Date: String]()
    
    public static let shared = MessageDateFormatter()

    private let formatter = DateFormatter()

    public func string(from date: Date) -> String {
        if let cached = cache[date] {
            return cached
        }
        configureDateFormatter(for: date)
        let x = formatter.string(from: date)
        cache[date] = x
        return x
    }


    public func timeAgo(from date: Date) -> String {
        if let cached = timeAgoCache[date] {
            return cached
        }
        
        let x = date.EXT_timeAgo()
        timeAgoCache[date] = x
        return x
    }

    public func attributedString(from date: Date, with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let dateString = string(from: date)
        return NSAttributedString(string: dateString, attributes: attributes)
    }

    open func configureDateFormatter(for date: Date) {
        switch true {
        case Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date):
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear):
            formatter.dateFormat = "EEEE, h:mm a"
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year):
            formatter.dateFormat = "EEE d MMM, h:mm a"
        default:
            formatter.dateFormat = "d MMM yyyy, h:mm a"
        }
    }
    
    
    static func timeAgoString(date: Date) -> String {
        let secondsInterval = Date().timeIntervalSince(date).rounded()
        if (secondsInterval < 10) {
            return "now"
        }
        if (secondsInterval < 60) {
            return String(Int(secondsInterval)) + " seconds ago"
        }
        let minutes = (secondsInterval / 60).rounded()
        if (minutes < 60) {
            return String(Int(minutes)) + " minutes ago"
        }
        let hours = (minutes / 60).rounded()
        if (hours < 24) {
            return String(Int(hours)) + " hours ago"
        }
        let days = (hours / 60).rounded()
        if (days < 30) {
            return String(Int(days)) + " days ago"
        }
        let months = (days / 30).rounded()
        if (months < 12) {
            return String(Int(months)) + " months ago"
        }
        let years = (months / 12).rounded()
        return String(Int(years)) + " years ago"
    }

    static func string(for date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    static func chatString(for date: Date) -> String {
        let calendar = NSCalendar.current
        if calendar.isDateInToday(date) {
            return self.string(for: date, format: "HH:mm")
        }
        return self.string(for: date, format: "MMM dd")
    }
}
