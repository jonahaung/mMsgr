//
//  AttachmentManager.swift
//  InputBarAccessoryView
//
//  Copyright © 2017-2018 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 10/4/17.
//


import UIKit

public extension NSAttributedString.Key {
    
    static let autocompleted = NSAttributedString.Key("com.mMsgr.autocompletekey")
    static let autocompletedContext = NSAttributedString.Key("com.mMsgr.autocompletekey.context")
}


func binarySearch(_ array: [Friend], value: String) -> Friend? {
    
    var firstIndex = 0
    var lastIndex = array.count - 1
    var wordToFind: Friend?
    var count = 0
    
    while firstIndex <= lastIndex {
        
        count += 1
        let middleIndex = (firstIndex + lastIndex) / 2
        let middleValue = array[middleIndex]
        
        if middleValue.displayName == value {
            wordToFind = middleValue
            return wordToFind
        }
        if value.localizedCompare(middleValue.displayName) == ComparisonResult.orderedDescending {
            firstIndex = middleIndex + 1
        }
        if value.localizedCompare(middleValue.displayName) == ComparisonResult.orderedAscending {
            lastIndex = middleIndex - 1
        }
    }
    return wordToFind
}


open class AutocompleteManager: NSObject, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, MainCoordinatorDelegatee {
    
    lazy var friends = Friend.fetch(in: PersistenceManager.sharedInstance.viewContext, includePending: false, returnsObjectsAsFaults: false, predicate: NSPredicate(format: "uid != phoneNumber"), sortedWith: nil)
    
    deinit {
        Log("DEINIT: AutocompleteManager")
    }
    
    open weak var delegate: AutocompleteManagerDelegate?

    private(set) weak var textView: UITextView?
    
    private(set) var currentSession: AutocompleteSession?

    open lazy var tableView: AutocompleteTableView = { [weak self] in
        
        $0.delegate = self
        $0.dataSource = self
        $0.register(AutocompleteCell.self)
        return $0
        }(AutocompleteTableView())
   
    open var isCaseSensitive = false
    
    open var appendSpaceOnCompletion = true
    
    open var keepPrefixOnCompletion = true
    
    open var maxSpaceCountDuringCompletion: Int = 5
    
    open var deleteCompletionByParts = true
    
    public let paragraphStyle: NSMutableParagraphStyle = {
        $0.paragraphSpacingBefore = 2
        $0.lineHeightMultiple = 1
        return $0  
    }(NSMutableParagraphStyle())
    
    public private(set) var autocompletePrefixes = Set<String>()
    
    public private(set) var autocompleteDelimiterSets: Set<CharacterSet> = []
    
    public private(set) var autocompleteTextAttributes = [String: [NSAttributedString.Key: Any]]()

    private var currentAutocompleteOptions: [Friend] {
        guard let session = currentSession, !session.filter.isEmpty else { return [] }
        let completions = session.prefix == "@" ? friends : []
        return completions.filter { $0.displayName.contains(session.filter, caseSensitive: isCaseSensitive) }.slice(length: 5)
    }

    private var previousSession: AutocompleteSession?
    
     init(for textView: UITextView) {
        super.init()
        self.textView = textView

    }

    @objc open func reloadData() {
        var delimiterSet = autocompleteDelimiterSets.reduce(CharacterSet()) { result, set in
            return result.union(set)
        }
        
        let query = textView?.find(prefixes: autocompletePrefixes, with: delimiterSet)
        guard let result = query else {
            if let session = currentSession, session.spaceCounter <= maxSpaceCountDuringCompletion {
                delimiterSet = delimiterSet.subtracting(.whitespaces)
                guard let result = textView?.find(prefixes: [session.prefix], with: delimiterSet) else {
                    unregisterCurrentSession()
                    return
                }
                let wordWithoutPrefix = (result.word as NSString).substring(from: result.prefix.utf16.count)
                updateCurrentSession(to: wordWithoutPrefix)
            } else {
                unregisterCurrentSession()
            }
            return
        }
        let wordWithoutPrefix = (result.word as NSString).substring(from: result.prefix.utf16.count)
        guard let session = AutocompleteSession(prefix: result.prefix, range: result.range, filter: wordWithoutPrefix) else { return }
        guard let currentSession = currentSession else {
            registerCurrentSession(to: session)
            return
        }
        if currentSession == session {
            updateCurrentSession(to: wordWithoutPrefix)
        } else {
            registerCurrentSession(to: session)
        }
    }
    
    open func invalidate() {
        unregisterCurrentSession()
    }
    
    @discardableResult
    open func handleInput(of object: AnyObject) -> Bool {
        guard let newText = object as? String, let textView = textView else { return false }
        let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        
        let newAttributedString = NSAttributedString(string: newText, attributes: [NSAttributedString.Key.font: textView.font!])
        
        attributedString.append(newAttributedString)
        textView.attributedText = NSAttributedString()
        textView.attributedText = attributedString
        reloadData()
        return true
    }
    
    open func register(prefix: String, with attributedTextAttributes: [NSAttributedString.Key:Any]? = nil) {
        autocompletePrefixes.insert(prefix)
        self.textView?.delegate = self
    }
    
    open func unregister(prefix: String) {
        autocompletePrefixes.remove(prefix)
        autocompleteTextAttributes[prefix] = nil
    }
    
    open func register(delimiterSet set: CharacterSet) {
        autocompleteDelimiterSets.insert(set)
    }
    
    open func unregister(delimiterSet set: CharacterSet) {
        autocompleteDelimiterSets.remove(set)
    }

    open func autocomplete(with session: AutocompleteSession) {

        guard let textView = textView else { return }
       
        // Create a range that overlaps the prefix
        let prefixLength = session.prefix.utf16.count
        let insertionRange = NSRange(
            location: session.range.location + (keepPrefixOnCompletion ? prefixLength : 0),
            length: session.filter.utf16.count + (!keepPrefixOnCompletion ? prefixLength : 0)
        )
        
        // Transform range
        guard let range = Range(insertionRange, in: textView.text) else { return }
        let nsrange = NSRange(range, in: textView.text)
        
        let autocomplete: String = {
            guard let friend = session.friend, let phone = friend.phoneNumber, let urlString = friend.photoURL?.absoluteString,  let country = friend.country else { return ""}
            let name = friend.displayName.camelCased
            return "\(name) \(country) \(phone) \(urlString)"
        }()
        insertAutocomplete(autocomplete, at: session, for: nsrange)
        
        // Move Cursor to the end of the inserted text
        let selectedLocation = insertionRange.location + autocomplete.utf16.count + (appendSpaceOnCompletion ? 1 : 0)
        textView.selectedRange = NSRange(
            location: selectedLocation,
            length: 0
        )
        unregisterCurrentSession()
    }

    open func textLabelAttributedText(matching session: AutocompleteSession) -> NSMutableAttributedString {
        guard let friend = session.friend else {
            return NSMutableAttributedString()
        }
        let matchingRange = (friend.displayName as NSString).range(of: session.filter, options: .caseInsensitive)
        let attributedString = NSMutableAttributedString(string: friend.displayName, attributes: [.font: UIFont.preferredFont(forTextStyle: .callout)])
        attributedString.addAttributes([.foregroundColor: GlobalVar.theme.mainColor], range: matchingRange)
        return attributedString
    }
    
  
    

    private func insertAutocomplete(_ autocomplete: String, at session: AutocompleteSession, for range: NSRange) {
        
        guard let textView = textView else { return }
        
        // Apply the autocomplete attributes
        var attrs = autocompleteTextAttributes[session.prefix] ?? textView.typingAttributes
        attrs[.autocompleted] = true
        attrs[.autocompletedContext] = session.friend
        let newString = (keepPrefixOnCompletion ? session.prefix : "") + autocomplete
        let newAttributedString = NSAttributedString(string: newString, attributes: attrs)
        
        // Modify the NSRange to include the prefix length
        let rangeModifier = keepPrefixOnCompletion ? session.prefix.count : 0
        let highlightedRange = NSRange(location: range.location - rangeModifier, length: range.length + rangeModifier)
        
        // Replace the attributedText with a modified version including the autocompete
        let newAttributedText = textView.attributedText.replacingCharacters(in: highlightedRange, with: newAttributedString)
        if appendSpaceOnCompletion {
            newAttributedText.append(NSAttributedString(string: " ", attributes: textView.typingAttributes))
        }
        
//        // Set to a blank attributed string to prevent keyboard autocorrect from cloberring the insert
//        textView.attributedText = NSAttributedString()
//
        textView.attributedText = newAttributedText
    }
    
   
    private func registerCurrentSession(to session: AutocompleteSession) {
        
        guard delegate?.autocompleteManager(self, shouldRegister: session.prefix, at: session.range) != false else { return }
        if let previousSession = previousSession, session == previousSession {
            currentSession = previousSession
            updateCurrentSession(to: session.filter)
        } else {
            currentSession = session
            layoutIfNeeded()
            delegate?.autocompleteManager(self, shouldBecomeVisible: true)
        }
    }
    

    private func updateCurrentSession(to filterText: String) {
        
        currentSession?.filter = filterText
        layoutIfNeeded()
        delegate?.autocompleteManager(self, shouldBecomeVisible: true)
    }
    
    /// Invalidates the `currentSession` session if it existed
    private func unregisterCurrentSession() {
        
        guard let session = currentSession else { return }
        guard delegate?.autocompleteManager(self, shouldUnregister: session.prefix) != false else { return }
        previousSession = currentSession
        currentSession = nil
        layoutIfNeeded()
        delegate?.autocompleteManager(self, shouldBecomeVisible: false)
    }
    
    /// Calls the required methods to relayout the `AutocompleteTableView` in it's superview
    private func layoutIfNeeded() {
        tableView.reloadData()
        tableView.invalidateIntrinsicContentSize()
        tableView.superview?.layoutIfNeeded()
        if tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
       
    }
    
    
    // MARK: - UITextViewDelegate
    
    public func textViewDidChange(_ textView: UITextView) {
        delegate?.autocompleteManager(self, textViewDidChange: textView)
        reloadData()
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        

        if let session = currentSession {
            let textToReplace = (textView.text as NSString).substring(with: range)
            let deleteSpaceCount = textToReplace.filter { $0 == .space }.count
            let insertSpaceCount = text.filter { $0 == .space }.count
            let spaceCountDiff = insertSpaceCount - deleteSpaceCount
            session.spaceCounter += spaceCountDiff
        }
        
        let totalRange = NSRange(location: 0, length: textView.attributedText.length)
        let selectedRange = textView.selectedRange
        
        // range.length > 0: Backspace/removing text
        // range.lowerBound < textView.selectedRange.lowerBound: Ignore trying to delete
        //      the substring if the user is already doing so
        // range == selectedRange: User selected a chunk to delete
        if range.length > 0, range.location < selectedRange.location {
            
            // Backspace/removing text
            let attributes = textView.attributedText.attributes(at: range.location, longestEffectiveRange: nil, in: range)
            let isAutocompleted = attributes[.autocompleted] as? Bool ?? false
            
            if isAutocompleted {
                textView.attributedText.enumerateAttribute(.autocompleted, in: totalRange, options: .reverse) { _, subrange, stop in
                    
                    let intersection = NSIntersectionRange(range, subrange)
                    guard intersection.length > 0 else { return }
                    defer { stop.pointee = true }
                    
                    let nothing = NSAttributedString(string: "", attributes: textView.typingAttributes)
                    
                    let textToReplace = textView.attributedText.attributedSubstring(from: subrange).string
                    guard deleteCompletionByParts, let delimiterRange = textToReplace.rangeOfCharacter(from: .whitespacesAndNewlines, options: .backwards, range: Range(subrange, in: textToReplace)) else {
                        // Replace entire autocomplete
                        textView.attributedText = textView.attributedText.replacingCharacters(in: subrange, with: nothing)
                        textView.selectedRange = NSRange(location: subrange.location, length: 0)
                        return
                    }
                    // Delete up to delimiter
                    let delimiterLocation = delimiterRange.lowerBound.utf16Offset(in: textView.text)
                    let length = subrange.length - delimiterLocation
                    let rangeFromDelimiter = NSRange(location: delimiterLocation + subrange.location, length: length)
                    textView.attributedText = textView.attributedText.replacingCharacters(in: rangeFromDelimiter, with: nothing)
                    textView.selectedRange = NSRange(location: subrange.location + delimiterLocation, length: 0)
                }
                unregisterCurrentSession()
                return false
            }
        } else if range.length >= 0, range.location < totalRange.length {
            
            // Inserting text in the middle of an autocompleted string
            let attributes = textView.attributedText.attributes(at: range.location, longestEffectiveRange: nil, in: range)
            let isAutocompleted = attributes[.autocompleted] as? Bool ?? false
            if isAutocompleted {
                textView.attributedText.enumerateAttribute(.autocompleted, in: totalRange, options: .reverse) { _, subrange, stop in
                    
                    let compareRange = range.length == 0 ? NSRange(location: range.location, length: 1) : range
                    let intersection = NSIntersectionRange(compareRange, subrange)
                    guard intersection.length > 0 else { return }
                    
                    let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
                    mutable.setAttributes(textView.typingAttributes, range: subrange)
                    let replacementText = NSAttributedString(string: text, attributes: textView.typingAttributes)
                    textView.attributedText = mutable.replacingCharacters(in: range, with: replacementText)
                    textView.selectedRange = NSRange(location: range.location + text.count, length: 0)
                    stop.pointee = true
                }
                unregisterCurrentSession()
                return false
            }
        }
        return true
    }
    
    // MARK: - UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentAutocompleteOptions.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let session = currentSession else { fatalError("Attempted to render a cell for a nil `AutocompleteSession`") }
        session.friend = currentAutocompleteOptions[indexPath.row]
        
        
        let cell: AutocompleteCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.nameLabel.attributedText = self.textLabelAttributedText(matching: session)
        
        if let friend = session.friend {
            cell.phoneLabel.text = friend.phoneNumber
            cell.phoneLabel.sizeToFit()
            cell.profileImageView.loadImage(for: friend, refresh: false)
        } else {

            cell.profileImageView.currentImage = UIImage(systemName: "person.circle.fill")
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard tableView.isSafeToSelect(indexPath: indexPath), let session = currentSession else { return }
        session.friend = currentAutocompleteOptions[indexPath.row]
        autocomplete(with: session)
    }
}


internal extension UITextView {
    
    func find(prefixes: Set<String>, with delimiterSet: CharacterSet) -> (prefix: String, word: String, range: NSRange)? {
        guard prefixes.count > 0,
            let result = wordAtCaret(with: delimiterSet),
            !result.word.isEmpty
            else { return nil }
        for prefix in prefixes {
            if result.word.hasPrefix(prefix) {
                return (prefix, result.word, result.range)
            }
        }
        return nil
    }
    
    func wordAtCaret(with delimiterSet: CharacterSet) -> (word: String, range: NSRange)? {
        guard let caretRange = self.caretRange,
            let result = text.word(at: caretRange, with: delimiterSet)
            else { return nil }

        let location = result.range.lowerBound.utf16Offset(in: self.text)
        let range = NSRange(location: location, length: result.range.upperBound.utf16Offset(in: self.text) - location)

        return (result.word, range)
    }

    var caretRange: NSRange? {
        guard let selectedRange = self.selectedTextRange else { return nil }
        return NSRange(
            location: offset(from: beginningOfDocument, to: selectedRange.start),
            length: offset(from: selectedRange.start, to: selectedRange.end)
        )
    }
    
}


 extension NSMutableAttributedString {
    
    @discardableResult
    func bold(_ text: String, fontSize: CGFloat = UIFont.buttonFontSize, textColor: UIColor = UIColor.randomColor()) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key:AnyObject] = [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor : textColor
        ]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult
    func medium(_ text: String, fontSize: CGFloat = UIFont.labelFontSize, textColor: UIColor = UIColor.randomColor()) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key:AnyObject] = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium),
            NSAttributedString.Key.foregroundColor : textColor
        ]
        let mediumString = NSMutableAttributedString(string: text, attributes: attrs)
        self.append(mediumString)
        return self
    }
    
    @discardableResult
    func italic(_ text: String, fontSize: CGFloat = UIFont.labelFontSize, textColor: UIColor = UIColor.randomColor()) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key:AnyObject] = [
            NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor : textColor
        ]
        let italicString = NSMutableAttributedString(string: text, attributes: attrs)
        self.append(italicString)
        return self
    }
    
    @discardableResult
    func normal(_ text: String, font: UIFont, textColor: UIColor) -> NSMutableAttributedString {
        let attrs:[NSAttributedString.Key:AnyObject] = [.font : font, .foregroundColor : textColor]
        let x =  NSMutableAttributedString(string: text, attributes: attrs)
        self.append(x)
        return self
    }
    @discardableResult
    func color(_ text: String, font: UIFont, textColor: UIColor) -> NSMutableAttributedString {
        let attrs:[NSAttributedString.Key:AnyObject] = [.font : font, .foregroundColor : textColor]
        let x =  NSMutableAttributedString(string: text, attributes: attrs)
        self.append(x)
        return self
    }
}

internal extension NSAttributedString {
    
    func replacingCharacters(in range: NSRange, with attributedString: NSAttributedString) -> NSMutableAttributedString {
        let ns = NSMutableAttributedString(attributedString: self)
        ns.replaceCharacters(in: range, with: attributedString)
        return ns
    }
    
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let ns = NSMutableAttributedString(attributedString: lhs)
        ns.append(rhs)
        lhs = ns
    }
    
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let ns = NSMutableAttributedString(attributedString: lhs)
        ns.append(rhs)
        return NSAttributedString(attributedString: ns)
    }
    
}

internal extension String {
//
    func wordParts(_ range: Range<String.Index>, _ delimiterSet: CharacterSet) -> (left: String.SubSequence, right: String.SubSequence)? {
        let leftView = self[..<range.upperBound]
        let leftIndex = leftView.rangeOfCharacter(from: delimiterSet, options: .backwards)?.upperBound
            ?? leftView.startIndex

        let rightView = self[range.upperBound...]
        let rightIndex = rightView.rangeOfCharacter(from: delimiterSet)?.lowerBound
            ?? endIndex

        return (leftView[leftIndex...], rightView[..<rightIndex])
    }
    
    func word(at nsrange: NSRange, with delimiterSet: CharacterSet) -> (word: String, range: Range<String.Index>)? {
        guard !isEmpty,
            let range = Range(nsrange, in: self),
            let parts = self.wordParts(range, delimiterSet)
            else { return nil }

        // if the left-next character is in the delimiterSet, the "right word part" is the full word
        // short circuit with the right word part + its range
        if let characterBeforeRange = index(range.lowerBound, offsetBy: -1, limitedBy: startIndex),
            let character = self[characterBeforeRange].unicodeScalars.first,
            delimiterSet.contains(character) {
            let right = parts.right
            let word = String(right)
            return (word, right.startIndex ..< right.endIndex)
        }

        let joinedWord = String(parts.left + parts.right)
        guard !joinedWord.isEmpty else { return nil }
        return (joinedWord, parts.left.startIndex ..< parts.right.endIndex)
    }
}

extension Character {
    
    static var space: Character {
        return " "
    }
}


extension String {
    func index(of pattern: String) -> Index? {
        // Cache the length of the search pattern because we're going to
        // use it a few times and it's expensive to calculate.
        let patternLength = pattern.count
        guard patternLength > 0, patternLength <= count else { return nil }
        
        // Make the skip table. This table determines how far we skip ahead
        // when a character from the pattern is found.
        var skipTable = [Character: Int]()
        for (i, c) in pattern.enumerated() {
            skipTable[c] = patternLength - i - 1
        }
        
        // This points at the last character in the pattern.
        let p = pattern.index(before: pattern.endIndex)
        let lastChar = pattern[p]
        
        // The pattern is scanned right-to-left, so skip ahead in the string by
        // the length of the pattern. (Minus 1 because startIndex already points
        // at the first character in the source string.)
        var i = index(startIndex, offsetBy: patternLength - 1)
        
        // This is a helper function that steps backwards through both strings
        // until we find a character that doesn’t match, or until we’ve reached
        // the beginning of the pattern.
        func backwards() -> Index? {
            var q = p
            var j = i
            while q > pattern.startIndex {
                j = index(before: j)
                q = index(before: q)
                if self[j] != pattern[q] { return nil }
            }
            return j
        }
        
        // The main loop. Keep going until the end of the string is reached.
        while i < endIndex {
            let c = self[i]
            
            // Does the current character match the last character from the pattern?
            if c == lastChar {
                
                // There is a possible match. Do a brute-force search backwards.
                if let k = backwards() { return k }
                
                // If no match, we can only safely skip one character ahead.
                i = index(after: i)
            } else {
                // The characters are not equal, so skip ahead. The amount to skip is
                // determined by the skip table. If the character is not present in the
                // pattern, we can skip ahead by the full pattern length. However, if
                // the character *is* present in the pattern, there may be a match up
                // ahead and we can't skip as far.
                i = index(i, offsetBy: skipTable[c] ?? patternLength, limitedBy: endIndex) ?? endIndex
            }
        }
        return nil
    }
}
