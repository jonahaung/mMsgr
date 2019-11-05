//
//  WordEmbedder.swift
//  mMsgr
//
//  Created by Aung Ko Min on 27/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import NaturalLanguage

final class WordEmbedder {
    
    private let embedder = NLEmbedding.wordEmbedding(for: .english)
    
    func predictSentiment(from text: String, completion: (String?) -> Void) {
        embedder?.enumerateNeighbors(for: text.lowercased(), maximumCount: 15) { (string, distance) -> Bool in
            //3
            print("\(string) - \(distance)")
            completion(string)
            return true
        }
    }
}
