//
//  AutocompleteTextView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 6/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit


protocol AutocompleteTextFieldCompletionSource: class {
    func autocompleteTextFieldCompletionSource(_ autocompleteTextField: AutocompleteTextView, forText text: String) -> String?
}


@objc protocol AutocompleteTextFieldDelegate: class {
    @objc optional func autocompleteTextFieldShouldBeginEditing(_ autocompleteTextField: AutocompleteTextView) -> Bool
    @objc optional func autocompleteTextFieldShouldEndEditing(_ autocompleteTextField: AutocompleteTextView) -> Bool
    @objc optional func autocompleteTextFieldShouldReturn(_ autocompleteTextField: AutocompleteTextView) -> Bool
    @objc optional func autocompleteTextField(_ autocompleteTextField: AutocompleteTextView, didTextChange text: String)
}

class AutocompleteTextView: GrowingTextView {
    
    var highlightColor = UIColor.myAppYellow
    
    weak var completionSource: AutocompleteTextFieldCompletionSource?
    weak var autocompleteDelegate: AutocompleteTextFieldDelegate?
    
    var completionRange: NSRange?
    var lastReplacement: String?
    
    override var font: UIFont? {
        get {
            return UIFont.preferredFont(forTextStyle: .body)
        }
        set {
        
        }
    
    }
}


extension AutocompleteTextView: GrowingTextViewDelegate {
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        lastReplacement = text
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        removeCompletion()
        
        // Try setting a completion if we're not deleting and we're typing at the end of the text field.
        let isAtEnd = selectedTextRange?.start == endOfDocument
        let textBeforeCompletion = text
        let isEmpty = lastReplacement?.isEmpty ?? true
        if !isEmpty, isAtEnd, markedTextRange == nil,
            let completion = completionSource?.autocompleteTextFieldCompletionSource(self, forText: text ?? "") {
            setCompletion(completion)
        }
        
        // Fire the delegate with the text the user typed (not including the completion).
        autocompleteDelegate?.autocompleteTextField?(self, didTextChange: textBeforeCompletion ?? "")
    }
    
    override func deleteBackward() {
        lastReplacement = nil
        
        guard completionRange == nil else {
            // If we have an active completion, delete it without deleting any user-typed characters.
            removeCompletion()
            return
        }
        
        super.deleteBackward()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return autocompleteDelegate?.autocompleteTextFieldShouldBeginEditing?(self) ?? true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        applyCompletion()
        return autocompleteDelegate?.autocompleteTextFieldShouldEndEditing?(self) ?? true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        applyCompletion()
        super.touchesBegan(touches, with: event)
    }
    override func caretRect(for position: UITextPosition) -> CGRect {
        return (completionRange != nil) ? CGRect.zero : super.caretRect(for: position)
    }
    
    override func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        removeCompletion()
        super.setMarkedText(markedText, selectedRange: selectedRange)
    }
    
    func highlightAll() {
        let text = self.text
        self.text = nil
        setCompletion(text ?? "")
        selectedTextRange = textRange(from: beginningOfDocument, to: beginningOfDocument)
    }
    
    private func applyCompletion() {
        guard completionRange != nil else { return }
        
        completionRange = nil
        
        // Clear the current completion, then set the text without the attributed style.
        // The attributed string must have at least one character to clear the current style.
        let text = self.text ?? ""
        attributedText = NSAttributedString(string: " ", attributes: typingAttributes)
        
        self.text = text
        
        // Move the cursor to the end of the completion.
        selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
    }
    
    private func removeCompletion() {
        guard let completionRange = completionRange else { return }
        
        applyCompletion()
        
        // Fixes: https://github.com/mozilla-mobile/focus-ios/issues/630
        // Prevents the hard crash when you select all and start a new query
        guard let count = text?.count, count > 1 else { return }
        
        text = (text as NSString?)?.replacingCharacters(in: completionRange, with: "")
    }
    
    private func setCompletion(_ completion: String) {
        let text = self.text ?? ""
        
        // Ignore this completion if it's empty or doesn't start with the current text.
        guard !completion.isEmpty, completion.lowercased().hasPrefix(text.lowercased()) else { return }
        
        // Add the completion suffix to the current text and highlight it.
        let completion = String(completion[completion.index(completion.startIndex, offsetBy: text.count)])
        let attributed = NSMutableAttributedString(string: text + completion, attributes: [.font: UIFont.preferredFont(forTextStyle: .body)])
        let range = NSMakeRange((text as NSString).length, (completion as NSString).length)
        attributed.addAttribute(NSAttributedString.Key.backgroundColor, value: highlightColor, range: range)
        attributedText = attributed
        completionRange = range
    }
}



class DomainCompletionSource: AutocompleteTextFieldCompletionSource {
    private var topDomains: [String] = {
        let filePath = Bundle.main.path(forResource: "topdomains", ofType: "txt")
        return try! String(contentsOfFile: filePath!).components(separatedBy: "\n")
    }()

    func autocompleteTextFieldCompletionSource(_ autocompleteTextField: AutocompleteTextView, forText text: String) -> String? {
        guard !text.isEmpty else { return nil }

        for domain in self.topDomains {
            if let completion = self.completion(forDomain: domain, withText: text) {
                return completion
            }
        }

        return nil
    }
    private func completion(forDomain domain: String, withText text: String) -> String? {
        let domainWithDotPrefix: String = ".www.\(domain)"
        if let range = domainWithDotPrefix.range(of: ".\(text)", options: .caseInsensitive, range: nil, locale: nil) {
            // We don't actually want to match the top-level domain ("com", "org", etc.) by itself, so
            // so make sure the result includes at least one ".".
            let range = domainWithDotPrefix.index(range.lowerBound, offsetBy: 1)
            let matchedDomain: String = String(domainWithDotPrefix[range])
            if matchedDomain.contains(".") {
                return matchedDomain + "/"
            }
        }

        return nil
    }
}
