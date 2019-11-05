//
//  SpellCorrector.swift
//  mMsgr
//
//  Created by Aung Ko Min on 4/2/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//


import Foundation

/// Given a word, produce a set of possible alternatives with
/// letters transposed, deleted, replaced or rogue characters inserted
func edits(word: String) -> Set<String> {
    if word.isEmpty { return [] }
    
    let splits = word.indices.map {
        (word[word.startIndex..<$0], word[$0..<word.endIndex])
    }
   
    let deletes = splits.map { $0.0 + String($0.1.dropFirst()) } as [String]
    
    let transposes: [String] = splits.map { left, right in
        if let fst = right.first {
            let drop1 = right.dropFirst()
            if let snd = drop1.first {
                let drop2 = drop1.dropFirst()
                return "\(left)\(String(snd))\(String(fst))\(String(drop2))"
            }
        }
        return ""
        }.filter { !$0.isEmpty }
    
    let alphabet = "abcdefghijklmnopqrstuvwxyz"
    
    let replaces = splits.flatMap { left, right in
        alphabet.map { "\(left)\(String($0))\(String(right.dropFirst()))" }
    }
    
    let inserts = splits.flatMap { left, right in
        alphabet.map { "\(left)\(String($0))\(right)" }
    }
    
    return Set(deletes + transposes + replaces + inserts)
}



class SpellCorrector {
    
    var knownWords: [String: Int] = [:]
    
    func train(_ word: String) {
        knownWords[word] = knownWords[word] != nil ? knownWords[word]! + 1 : 1
    }
    
    init(strings: [String]) {
        
        for word in strings {
            self.train(word)
        }
    }
    
    convenience init?(contentsOfFile file: String) {
        
        guard let url = URL(string: file) else {
            return nil
        }
        if let text = try? String(contentsOf: url, encoding: .utf8) {
            let ltext = text.lowercased()
            let words = ltext.split { !("a"..."z").contains($0) }.map { String($0) }
            self.init(strings : words)
        }
        else {
            return nil
        }
    }
    
    func knownEdits2(_ word: String) -> Set<String>? {
        var known_edits: Set<String> = []
        for edit in edits(word:word) {
            if let k = known(edits(word:edit)) {
                known_edits.formUnion(k)
            }
        }
        return known_edits.isEmpty ? nil : known_edits
    }
    
    func known<S: Sequence>(_ words: S) -> Set<String>? where S.Iterator.Element == String {
        let s = Set(words.filter { self.knownWords.index(forKey: $0) != nil })
        return s.isEmpty ? nil : s
    }
    
    func correct(word: String) -> String {
        let c = known([word]) ?? known(edits(word: word)) ?? knownEdits2(word)
        
        if let candidates = c, candidates.count > 0 {
            return candidates.reduce(word, { (s1, s2) -> String in
                return (knownWords[s1] ?? 0) < (knownWords[s2] ?? 0) ? s2 : s1
            })
        }
        else {
            return word
        }
    }
}
