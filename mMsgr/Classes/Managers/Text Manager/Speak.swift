//
//  Speak.swift
//  mMsgr
//
//  Created by Aung Ko Min on 12/1/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import AVFoundation

private let speechSynthesizer = AVSpeechSynthesizer()

extension String {
    func stopSpeak() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    func speak() {
        let lang = self.language
        if !speechSynthesizer.isSpeaking {
            
            if lang == "my" {

                
                let groups = self.components(separatedBy: " ")
                for group in groups {
                    let words = group.myanmarSegments
                   
                    var results = [String]()
                    
                    for word in words {
                        if let pronounce = Pronounce.fetch(word: word.urlEncoded)?.pronounce {
                            results.append(pronounce.trimmed)
                        }
                    }
                    
                    let result = results.joined(separator: " ")
                    
                    let speechUtterance = AVSpeechUtterance(string: result)
                    
                    speechUtterance.volume = 0.1
                    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en_GB")
                    speechSynthesizer.speak(speechUtterance)
                }
                
                return
            } else {
                let utterance = AVSpeechUtterance(string: self)
                speechSynthesizer.pauseSpeaking(at: .word)
                utterance.volume = 0.1
                utterance.voice = AVSpeechSynthesisVoice(language: lang)
                speechSynthesizer.speak(utterance)
            }
        } else {
            speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    var language: String? {
        return getLanguage()?.rawValue
    }
}
