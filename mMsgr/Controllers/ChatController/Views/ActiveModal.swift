//
//  ActiveModal.swift
//  mMsgr
//
//  Created by Aung Ko Min on 31/1/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation

enum ActiveElement {
    case mention(String)
    case hashtag(String)
    
    static func create(with activeType: ActiveType, text: String) -> ActiveElement {
        switch activeType {
        case .mention: return mention(text)
        case .hashtag: return hashtag(text)
        }
    }
}

public enum ActiveType {
    case mention
    case hashtag
    
    var pattern: String {
        switch self {
        case .mention: return RegexParser.mentionPattern
        case .hashtag: return RegexParser.hashtagPattern
        }
    }
}
typealias ElementTuple = (range: NSRange, element: ActiveElement, type: ActiveType)
extension ActiveType: Hashable, Equatable {
    public var hashValue: Int {
        switch self {
        case .mention: return -1
        case .hashtag: return -2
            
        }
    }
}

public func ==(lhs: ActiveType, rhs: ActiveType) -> Bool {
    switch (lhs, rhs) {
    case (.mention, .mention): return true
    case (.hashtag, .hashtag): return true
    default: return false
    }
}
