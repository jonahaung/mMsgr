/*
 The MIT License (MIT)
 
 Copyright (c) 2015-present Badoo Trading Limited.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

final class AccessoryViewRevealer: NSObject {
    
    private var panRecognizer = UIPanGestureRecognizer()
   
    private var canSpeak = true
    private weak var collectionView: ChatCollectionView?
    private weak var revalingCell: MessageCell?
    private var config = AccessoryViewRevealerConfig.defaultConfig()
    
    lazy var label: UILabel = {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote)
        $0.textColor = UIColor.n1MidGreyColor
        return $0
    }( UILabel())
    
    init(_collectionView: ChatCollectionView) {
        collectionView = _collectionView
        super.init()
        collectionView?.addGestureRecognizer(panRecognizer)
        panRecognizer.addTarget(self, action: #selector(AccessoryViewRevealer.handlePan(_:)))
        panRecognizer.delegate = self
    
        canSpeak = userDefaults.currentBoolObjectState(for: userDefaults.speakOutPannedMessages)
    }
    
    deinit {
        panRecognizer.delegate = nil
        collectionView?.removeGestureRecognizer(panRecognizer)
        print("DEINIT: AccessoryViewRevealer")
    }
    
    var canPerformGesture = true
}



// Pan

extension AccessoryViewRevealer {
    
    @objc private func handlePan(_ panRecognizer: UIPanGestureRecognizer) {
        guard let collectionView = self.collectionView else { return }
        panRecognizer.delaysTouchesBegan = true
        switch panRecognizer.state {
        case .began:
            let point = panRecognizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point), let cell = collectionView.cellForItem(at: indexPath) as? MessageCell {
                self.revalingCell = cell
            }
        case .changed:
            if let cell = self.revalingCell {
                if cell.timeLabel == nil {
                    cell.timeLabel = self.label
                }
                let translation = panRecognizer.translation(in: collectionView)
                if translation.x > 1 && translation.x < cell.bounds.width {
                    self.revealAccessoryViewForOther(atOffset: self.config.translationTransform(translation.x), cell: cell)
                } else if translation.x < -1 && translation.x < cell.bounds.width {
                    self.revealAccessoryViewForTime(atOffset: self.config.translationTransform(-translation.x), cell: cell)
                }
            }
        case .ended, .cancelled, .failed:
            self.unRevealAccessoryView()
            panRecognizer.delaysTouchesEnded = true
        default:
            panRecognizer.delaysTouchesEnded = true
        }
    }
    
    private func unRevealAccessoryView() {
        guard let cell = self.revalingCell else { return }
        cell.revealAccessoryView(withOffset: 0, canSpeak: canSpeak, animated: true)
        label.removeFromSuperview()
        self.revalingCell = nil
        panRecognizer.delaysTouchesEnded = true
    }
    
    private func revealAccessoryViewForTime(atOffset offset: CGFloat, cell: MessageCell) {
        let offset = min(offset, cell.bounds.width/2)
        guard let msg = cell.msg else { return }
        label.text = msg.date.dateTimeString(ofStyle: .short)
        cell.revealAccessoryView(withOffset: offset, canSpeak: canSpeak, animated: offset == 0)
    }
    
    private func revealAccessoryViewForOther(atOffset offset: CGFloat, cell: MessageCell) {
        let offset = min(offset, cell.bounds.width/2)
        guard let msg = cell.msg else { return }
        label.text = msg.date.EXT_timeAgo()
        cell.revealAccessoryView(withOffset: offset, canSpeak: canSpeak, animated: offset == 0)
    }
}

// Gesture Delegate

extension AccessoryViewRevealer: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard canPerformGesture else { return false }
        if gestureRecognizer == self.panRecognizer {
            return collectionView?.isSafeToInteract == true
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard canPerformGesture else { return false }
        if gestureRecognizer == self.panRecognizer {
            let translation = self.panRecognizer.translation(in: self.collectionView)
            let x = abs(translation.x), y = abs(translation.y)
            let angleRads = atan2(y, x)
            return angleRads <= self.config.angleThresholdInRads
        }

        return false
    }
}


public struct AccessoryViewRevealerConfig {
    public let angleThresholdInRads: CGFloat
    public let translationTransform: (_ rawTranslation: CGFloat) -> CGFloat
    public init(angleThresholdInRads: CGFloat, translationTransform: @escaping (_ rawTranslation: CGFloat) -> CGFloat) {
        self.angleThresholdInRads = angleThresholdInRads
        self.translationTransform = translationTransform
    }
    
    public static func defaultConfig() -> AccessoryViewRevealerConfig {
        return self.init(
            angleThresholdInRads: 0.0872665, // ~5 degrees
            translationTransform: { (rawTranslation) -> CGFloat in
                let threshold: CGFloat = 30
                return max(0, rawTranslation - threshold) / 2
        })
    }
}
