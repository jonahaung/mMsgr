//
//  ChatTextView.swift
//  mMsgr
//
//  Created by jonahaung on 13/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

typealias ElementTuple = (range: NSRange, element: ActiveElement, type: ActiveType)

final class MessageTextView: UITextView, MainCoordinatorDelegatee {
    
    private var parsing = false
    
    private var msgText: NSAttributedString?
    
    override var canBecomeFocused: Bool {
        return false
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    
    override var contentInset: UIEdgeInsets {
        get {
            return .zero
        }

        set {

        }
    }

    override var contentOffset: CGPoint {
        get {
            return .zero
        }

        set {

        }
    }
    private func setup() {
        backgroundColor = nil
        scrollsToTop = false
        bounces = false
        bouncesZoom = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isEditable = false
        isScrollEnabled = false
        isSelectable = false
        
        layoutManager.allowsNonContiguousLayout = true
        textContainer.lineFragmentPadding = 0
        let top = UIFontMetrics.default.scaledValue(for: 7)
        let left = UIFontMetrics.default.scaledValue(for: 13)
        textContainerInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
        isExclusiveTouch = true
        canCancelContentTouches = true
        delaysContentTouches = true
        isMultipleTouchEnabled = false
        
        textDragInteraction?.allowsSimultaneousRecognitionDuringLift = false
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension MessageTextView {
    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        return !parsing
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if let first = touches.first, !parsing {

            parsing = true
            parseForMentions(first.location(in: self))
        }
    }
    private func showWord(with touch: UITouch, wordLocation: CGPoint) {
        guard let word = self.getWordAtPosition(wordLocation) else { return }
        if let window = self.window {
            let point = touch.location(in: window)
            dropDownMessageBar.show(at: point,text: word, duration: TimeInterval(word.count/2))
        }
    }
}

extension MessageTextView {
    private func parseForMentions(_ location: CGPoint) {
        
        guard textStorage.length > 0 else {
            self.parsing = false
            return
        }
        let boundingRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: textStorage.length), in: textContainer)
        guard boundingRect.contains(location) else {
            self.parsing = false
            return
        }
        
        
        
        let index = layoutManager.glyphIndex(for: location, in: textContainer)
        
        let string = attributedText.string
        var elements = [ElementTuple]()
        var selectedElement: ElementTuple?
        
        Async.background {
            let range = NSRange(location: 0, length: string.utf16.count)
            
            let mentions = RegexParser.getElements(from: string, with: RegexParser.mentionPattern, range: range)
            for mention in mentions {
                
                if let word = string.word(at: mention.range)?.word {
                    let element = ActiveElement.create(with: .mention, text: word)
                    let turple = ElementTuple(mention.range, element, .mention)
                    elements.append(turple)
                }
            }
            
            let hashs = RegexParser.getElements(from: string, with: RegexParser.hashtagPattern, range: range)
            
            for hash in hashs {
                
                if let word = string.word(at: hash.range)?.word {
                    let element = ActiveElement.create(with: .hashtag, text: word)
                    let turple = ElementTuple(hash.range, element, .hashtag)
                    elements.append(turple)
                }
            }
            
            for element in elements {
                if index >= element.range.location && index <= element.range.location + element.range.length {
                    selectedElement = element
                    break
                }
            }
        }.main {[weak self] in
            guard let `self` = self else { return }
            self.msgText = self.attributedText
            guard self.parsing, let element = selectedElement, let msgText = self.msgText else {
                self.parsing = false
                return
            }
            
            let new = NSMutableAttributedString(attributedString: msgText)
            new.removeAttribute(.foregroundColor, range: element.range)
            new.addAttributes([.foregroundColor: UIColor.systemIndigo], range: element.range)
            self.attributedText = new
            SoundManager.playSound(tone: .Tock)
        }.main(after: 0.3) { [weak self] in
            
            guard let `self` = self else { return }
            
            guard self.parsing, let element = selectedElement else {
                self.parsing = false
                return
            }
            
            self.parsing = false
            self.attributedText = self.msgText
            switch element.element {
            case .mention(let userHandle):
                self.didTapMention(userHandle)
            case .hashtag(let hashtag):
                self.didTapHashtag(hashtag)
            }
        }
    }
    
    private func didTapMention(_ username: String) {
        let trimmed = username.replace(target: "@", withString: "").trimmed
        
        let name = trimmed.camelCaseToWords()
        print(name)
        let friend = Friend.findOrFetch(in: PersistenceManager.sharedInstance.viewContext, predicate: Friend.predicate(forDisplayName: name))
        gotoProfileController(for: friend)
    }
    
    private func didTapHashtag(_ hashtag: String) {
    }
}




extension UITextView {
    
    func getWordRangeAtPosition(_ point: CGPoint) -> UITextRange? {
        if let textPosition = self.closestPosition(to: point) {
            return tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 1))
        }
        return nil
    }
    
    func getWordAtPosition(_ point: CGPoint) -> String? {
        if let range = getWordRangeAtPosition(point) {
            return self.text(in: range)
        }
        return nil
    }
    func getAttributsAtPosition(_ point: CGPoint) -> [NSAttributedString.Key: Any]? {
        let characterIndex = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if let attributes = attributedText?.attributes(at: characterIndex, effectiveRange: nil) {
            return attributes
        }
        return nil
    }
}
