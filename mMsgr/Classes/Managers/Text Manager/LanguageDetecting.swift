//
//  TextTranslatable.swift
//  mMsgr
//
//  Created by Aung Ko Min on 10/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import Foundation

import NaturalLanguage

private let linguisticTagger = NSLinguisticTagger(tagSchemes: [.lemma, .language, .lexicalClass], options:0 )

private let languageRecognizer: NLLanguageRecognizer = {
    $0.languageConstraints = [NLLanguage.burmese, NLLanguage.english]
    return $0
}(NLLanguageRecognizer())

extension String {
    func getLanguage() -> NLLanguage? {
        languageRecognizer.reset()
        languageRecognizer.processString(self)
        return languageRecognizer.dominantLanguage
    }
}
