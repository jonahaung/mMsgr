//
//  InputBarManager.swift
//  mMsgr
//
//  Created by Aung Ko Min on 6/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import CoreData

protocol InputBarManagerDelegate: class {
    
    func inputBarManager(autocompleteManager manager: AutocompleteManager, shouldBecomeVisible: Bool)
    func inputBarManager(textViewDidChangeHeight textView: UITextView, height: CGFloat)
    func inputBarManager(textViewIsWriting isWritingText: Bool)
    func inputBarManager(textViewDidToggle isActive: Bool)
    func inputBarManager(didGetClassifiedText text: String?)
    func inputBarManager(didGetSuggestedText text: String?)
    func inputBarManager(didChangeInputLanguage language: String?)
    func inputBarManager(didAutocomplete text: String)
}

class InputBarManager: NSObject {
    
    weak var delegate: InputBarManagerDelegate?
    private let isZawGyiFont = userDefaults.currentBoolObjectState(for: userDefaults.isZawgyiInstalled)
    private let textView: InputBarTextView
    private var swipeRightGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    private lazy var autocompleteManager: AutocompleteManager = { [weak self] in
        $0.delegate = self
        return $0
        }(AutocompleteManager(for: textView))
    private lazy var context = PersistenceManager.sharedInstance.importerContext
    private let model = MyTextClassifier_()
    private(set) var isMyanmar: Bool = true
    private let queue: OperationQueue = {
        $0.qualityOfService = .background
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())
    
    private(set) var suggestedText: String? {
        didSet {
            guard oldValue != suggestedText else { return }
            textView.suggestedText = suggestedText
            delegate?.inputBarManager(didGetSuggestedText: suggestedText)
        }
    }
   
    private(set) var classifiedText: String? {
        didSet {
            guard oldValue != classifiedText else { return }
            delegate?.inputBarManager(didGetClassifiedText: classifiedText)
        }
    }
    
    
    init(_textView: InputBarTextView) {
        
        textView = _textView
        super.init()
        setupGestureRecognizer()
        observeInputLanguageChanged()
        textView.delegate = self
    }
    
    
    
    deinit {
        queue.cancelAllOperations()
        NotificationCenter.default.removeObserver(self)
        swipeRightGestureRecognizer.delegate = nil
        textView.removeGestureRecognizer(swipeRightGestureRecognizer)
        print("InputBarManager")
    }
}



extension InputBarManager: InputBarTextViewDelegate {
    
    func inputBarTextView(_ textView: InputBarTextView, isWritingText: Bool) {
        delegate?.inputBarManager(textViewIsWriting: isWritingText)
    }

    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        delegate?.inputBarManager(textViewDidChangeHeight: textView, height: height)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        isMyanmar = textView.textInputMode?.primaryLanguage == "my"
        delegate?.inputBarManager(textViewDidToggle: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
         delegate?.inputBarManager(textViewDidToggle: false)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "@" {
            autocompleteManager.register(prefix: text)
            return true
        }
        
        let subString = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if !subString.isEmpty && isMyanmar {
            findCompletions(text: subString)
        }
        
        return true
    }
    
    
}
private extension String {
    func bma_rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index> {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return  self.startIndex..<self.startIndex }
        return from ..< to
    }
}
extension InputBarManager {
    
    
    private func findCompletions(text: String) {
        
        queue.cancelAllOperations()
        
        let isMyanmar = self.isMyanmar
        let isZawGyi = self.isZawGyiFont
        queue.addOperation {[weak self] in
            guard let `self` = self else { return }
            
            let sentences = text.sentences
            let lastSentence = sentences.last ?? text
            let lastWord = lastSentence.lastWord.trimmed
            
            var suggestingText: String?
            var classifyingText: String?
            
            if isMyanmar {
                let prediction = try? self.model.prediction(text: text)
                classifyingText = prediction?.label
                suggestingText = Dic.completion(for: lastWord, in: self.context, isZawGyi: isZawGyi)
            }else {
                if let suggestions = textChecker.completions(forPartialWordRange: NSRange(0..<lastWord.count), in: lastWord, language: "en-US")  {
                    let sorted = suggestions.sorted{ $0.count > $1.count }
                    guard let first = sorted.first else { return }
                    
                    suggestingText = String(first.dropFirst(lastWord.utf16.count))
                }
            }
            OperationQueue.main.addOperation {
                self.suggestedText = suggestingText
                if isMyanmar {
                    self.classifiedText = classifyingText
                }
            }
        }
    }

}


extension InputBarManager: AutocompleteManagerDelegate {
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        delegate?.inputBarManager(autocompleteManager: manager, shouldBecomeVisible: shouldBecomeVisible)
        if !shouldBecomeVisible {
            textView.delegate = self
        }
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldRegister prefix: String, at range: NSRange) -> Bool {
        return true
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldUnregister prefix: String) -> Bool {
        return true
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldComplete prefix: String, with text: String) -> Bool {
        delegate?.inputBarManager(didAutocomplete: text)
        return true
    }
    func autocompleteManager(_ manager: AutocompleteManager, textViewDidChange textView: UITextView) {
        
    }
}


extension InputBarManager {
    
    
    private func setupGestureRecognizer() {
        
        swipeRightGestureRecognizer.direction = .right
        swipeRightGestureRecognizer.addTarget(self, action: #selector(InputBarManager.swipeRight(_:)))
        textView.addGestureRecognizer(swipeRightGestureRecognizer)
        
        swipeRightGestureRecognizer.delegate = self
        
    }
    
    @objc private func swipeRight(_ gesture: UISwipeGestureRecognizer) {
        gesture.delaysTouchesBegan = true
        if let text = self.textView.text, !text.isEmpty {
            
            if let suggestion = suggestedText {
                suggestedText = nil
                textView.insertText(suggestion+" ")
                vibrate(vibration: .light)
                gesture.delaysTouchesEnded = true
                Async.background {
                    Dic.updateRank(for: text.lastWord, in: self.context)
                }
                
            } else {
                if text.hasSuffix(" ") {
                    textView.deleteBackward()
                    gesture.delaysTouchesEnded = true
                    return
                }
                (1...text.lastWord.utf16.count).forEach { _ in
                    textView.deleteBackward()
                    vibrate(vibration: .light)
                }
                gesture.delaysTouchesEnded = true
            }
        }
    }
}

extension InputBarManager {

    fileprivate func observeInputLanguageChanged() {
        NotificationCenter.default.addObserver(self,selector: #selector(InputBarManager.changeInputMode(_:)), name: UITextInputMode.currentInputModeDidChangeNotification, object: nil)
    }
    
    @objc private func changeInputMode(_ notification: Notification?) {
        isMyanmar = textView.textInputMode?.primaryLanguage == "my"
        delegate?.inputBarManager(didChangeInputLanguage: textView.textInputMode?.primaryLanguage)
    }
}
extension InputBarManager: UIGestureRecognizerDelegate {
    
}
