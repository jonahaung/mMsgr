//
//  RegexParser.swift
//  mMsgr
//
//  Created by Aung Ko Min on 14/1/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation

struct RegexParser {
    
    static let hashtagPattern = "(?:^|\\s|$)#[\\p{L}0-9_]*"
    static let mentionPattern = "(?:^|\\s|$|[.])@[\\p{L}0-9_]*"
    static let urlPattern = "(^|[\\s.:;?\\-\\]<\\(])" +
        "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
    "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
    static let phonePattern = "(?:(\\+\\d\\d\\s+)?((?:\\(\\d\\d\\)|\\d\\d)\\s+)?)(\\d{4,5}\\-?\\d{4})"
   static let myanmarWordsBreakerPattern = "(?:(?<!\\u1039)([\\u1000-\\u102A\\u103F\\u104A-\\u104F]|[\\u1040-\\u1049]+|[^\\u1000-\\u104F]+)(?![\\u103E\\u103B]?[\\u1039\\u103A\\u1037]))"
    
    private static var cachedRegularExpressions: [String : NSRegularExpression] = [:]
    
    static func getElements(from text: String, with pattern: String, range: NSRange) -> [NSTextCheckingResult]{
        guard let elementRegex = regularExpression(for: pattern) else { return [] }
        return elementRegex.matches(in: text, options: [], range: range)
    }
    
    static func regularExpression(for pattern: String) -> NSRegularExpression? {
        if let regex = cachedRegularExpressions[pattern] {
            return regex
        } else if let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            cachedRegularExpressions[pattern] = createdRegex
            return createdRegex
        } else {
            return nil
        }
    }

}

