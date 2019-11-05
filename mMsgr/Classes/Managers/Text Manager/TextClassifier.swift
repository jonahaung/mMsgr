//
//  TextClassifier.swift
//  mMsgr
//
//  Created by Aung Ko Min on 24/4/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation

private let smoothingParameter = 1.0
var tagger = Tagger(seed: Seed())

enum Category: String {
    case Business, Normal, Abusve
}

class TextClassifier {
    
    typealias Word = String
    
    var categoryOccurrences: [Category: Int] = [:]
    var wordOccurrences: [Word: [Category: Int]] = [:]
    var trainingCount = 0
    var wordCount = 0
    
    // MARK: - Training
    func trainWithText(_ text: String, category: Category) {
        let taggedTokens = tagger.tagWordsInText(text: text.lowercased().trimmed, scheme: NSLinguisticTagScheme.lexicalClass.rawValue, options: [.omitWhitespace, .omitPunctuation])
        let tokens = taggedTokens.map{ $0.token }
        trainWithTokens(tokens: tokens, category: category)
    }
    
    func trainWithTokens(tokens: [Word], category: Category) {
        let words = Set(tokens)
        for word in words {
            incrementWord(word: word, category: category)
        }
        incrementCategory(category: category)
        trainingCount += 1
    }
    
    // MARK: - Classifying
    func classify(_ text: String) -> Category? {
        let taggedTokens = tagger.tagWordsInText(text: text.lowercased().trimmed, scheme: NSLinguisticTagScheme.lexicalClass.rawValue, options: [.omitWhitespace, .omitPunctuation])
        let tokens = taggedTokens.map{ $0.token }
        return classifyTokens(tokens: tokens)
    }
    
    func classifyTokens(tokens: [Word]) -> Category? {
        // Compute argmax_cat [log(P(C=cat)) + sum_token(log(P(W=token|C=cat)))]
        return argmax(elements: categoryOccurrences.map { (category, count) -> (Category, Double) in
            let pCategory = self.P(category: category)
            let score = tokens.reduce(log(pCategory)) { (total, token) in
                total + log((self.P(category: category, token) + smoothingParameter) / (pCategory + smoothingParameter + Double(self.wordCount)))
            }
            return (category, score)
        })
    }
    
    // MARK: - Probabilites
    private func P(category: Category, _ word: Word) -> Double {
        if let occurrences = wordOccurrences[word] {
            let count = occurrences[category] ?? 0
            return Double(count) / Double(trainingCount)
        }
        return 0.0
    }
    
    private func P(category: Category) -> Double {
        return Double(totalOccurrencesOfCategory(category: category)) / Double(trainingCount)
    }
    
    // MARK: - Counting
    private func incrementWord(word: Word, category: Category) {
        if wordOccurrences[word] == nil {
            wordCount += 1
            wordOccurrences[word] = [:]
        }
        
        let count = wordOccurrences[word]?[category] ?? 0
        wordOccurrences[word]?[category] = count + 1
    }
    
    private func incrementCategory(category: Category) {
        categoryOccurrences[category] = totalOccurrencesOfCategory(category: category) + 1
    }
    
    private func totalOccurrencesOfWord(word: Word) -> Int {
        if let occurrences = wordOccurrences[word] {
            return Array(occurrences.values).reduce(0, +)
        }
        return 0
    }
    
    private func totalOccurrencesOfCategory(category: Category) -> Int {
        return categoryOccurrences[category] ?? 0
    }
}
