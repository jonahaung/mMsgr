//
//  String+Extensions.swift
//  mMsgr
//
//  Created by Aung Ko Min on 28/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//
import UIKit

extension CharacterSet {
    
    static var myanmarAlphabets: CharacterSet {
        return CharacterSet(charactersIn: "ကခဂဃငစဆဇဈညတဒဍဓဎထဋဌနဏပဖဗဘမယရလ၀သဟဠအဣဧဤဩဥ။")
    }
    static var englishAlphabets: CharacterSet {
        return CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    }
    static var engLineEnding: CharacterSet {
        return CharacterSet(charactersIn: ".?!;:\n\t။")
    }
    static var myaLineEnding: CharacterSet {
        return CharacterSet(charactersIn: ". ,?\t\n။")
    }
}

 extension String {
    
    var nsString: NSString {
        return NSString(string: self)
    }
    
    var trimForFirebase: String {
        return self.trimmingCharacters(in: CharacterSet.engLineEnding.union(.whitespacesAndNewlines)).lowercased()
    }
    
    static func emptyIfNil(_ string: String?) -> String {
        if let str = string {
            return str
        }
        return ""
    }
    
    
    var myanmarSegments: [String] {
        let regex = RegexParser.regularExpression(for: RegexParser.myanmarWordsBreakerPattern)
        let modString = regex?.stringByReplacingMatches(in: self, options: [], range: self.nsRange(of: self), withTemplate: "𝕊$1")
        return modString?.components(separatedBy: "𝕊").filter{ !$0.isWhitespace } ?? self.components(separatedBy: .whitespaces)
    }

    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    var doubleValue: Double {
        return Double(self) ?? 0
    }
    
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: .literal, range: nil)
    }
    
    var EXT_isMyanmar: Bool {
        return self.language == "my"
    }
    
    var EXT_isMyanmarCharacters: Bool {
        return self.rangeOfCharacter(from: CharacterSet.myanmarAlphabets) != nil
    }
    var EXT_isEnglishCharacters: Bool {
        return self.rangeOfCharacter(from: CharacterSet.englishAlphabets) != nil
    }

    var firstCharacterAsString: String? {
        guard let first = self.first else { return nil }
        return String(first)
    }
    
    var firstWord: String {
        return words().first ?? self
    }
    func lastWords(_ max: Int) -> [String] {
        return Array(words().suffix(max))
    }
    var lastWord: String {
        return words().last ?? self
    }
    
    
     var lastCharacterAsString: String? {
        guard let last = last else { return nil }
        return String(last)
    }

    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var urlDecoded: String {
        return removingPercentEncoding ?? self
    }
    
    var urlEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }
    
    var isWhitespace: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

     mutating func firstCharacterUppercased() {
        guard let first = first else { return }
        self = String(first).uppercased() + dropFirst()
    }
    
    var sentences: [String] {

        var sentences = [String]()
        guard let range = self.range(of: self) else { return []}

        self.enumerateSubstrings(in: range, options: .bySentences) { (substring, _, _, _) in
            if let x = substring {
                sentences.append(String(x))
            } else {
                sentences.append(self)
            }
            
        }
        return sentences
    }
    
    var withoutSpacesAndNewLines: String {
        return replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
    }

    var camelCased: String {
        let source = lowercased()
        let first = source[..<source.index(after: source.startIndex)]
        if source.contains(" ") {
            let connected = source.capitalized.replacingOccurrences(of: " ", with: "")
            let camel = connected.replacingOccurrences(of: "\n", with: "")
            let rest = String(camel.dropFirst())
            return first + rest
        }
        let rest = String(source.dropFirst())
        return first + rest
    }
    
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0.count > 0 {
                    return ($0 + " " + String($1))
                }
            }
            return $0 + String($1)
        }
    }
    func lines() -> [String] {
        var result = [String]()
        enumerateLines { line, _ in
            result.append(line)
        }
        return result
    }
    
    func words() -> [String] {
        let chararacterSet = CharacterSet.whitespacesAndNewlines
        let comps = components(separatedBy: chararacterSet)
        return comps.filter { !$0.isEmpty }
    }
    
     
    func contains(_ string: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return range(of: string, options: .caseInsensitive) != nil
        }
        return range(of: string) != nil
    }
    
    func nsRange(of word: String) -> NSRange {
        if let wordRange = self.range(of: word) {
            return NSRange(wordRange, in: self)
        }
        
        return NSRange(location: 0, length: 0)
    }
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }
    
    func wordParts(_ range: Range<String.Index>) -> (left: String.SubSequence, right: String.SubSequence)? {
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        let leftView = self[..<range.upperBound]
        let leftIndex = leftView.rangeOfCharacter(from: whitespace, options: .backwards)?.upperBound
            ?? leftView.startIndex
        
        let rightView = self[range.upperBound...]
        let rightIndex = rightView.rangeOfCharacter(from: whitespace)?.lowerBound
            ?? endIndex
        
        return (leftView[leftIndex...], rightView[..<rightIndex])
    }
    
    func word(at nsrange: NSRange) -> (word: String, range: Range<String.Index>)? {
        guard !isEmpty,
            let range = Range(nsrange, in: self),
            let parts = self.wordParts(range)
            else { return nil }
        
        // if the left-next character is whitespace, the "right word part" is the full word
        // short circuit with the right word part + its range
        if let characterBeforeRange = index(range.lowerBound, offsetBy: -1, limitedBy: startIndex),
            let character = self[characterBeforeRange].unicodeScalars.first,
            NSCharacterSet.whitespaces.contains(character) {
            let right = parts.right
            return (String(right), right.startIndex ..< right.endIndex)
        }
        
        let joinedWord = String(parts.left + parts.right)
        guard !joinedWord.isEmpty else { return nil }
        
        return (joinedWord, parts.left.startIndex ..< parts.right.endIndex)
    }
    
}
    
