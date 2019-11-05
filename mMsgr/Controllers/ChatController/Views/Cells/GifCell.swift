//
//  GifCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 6/12/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

var docURL = FileManager.default.EXT_documentsURL


extension Message {
    var gifURL: URL? {
        guard let appending = text2 else { return nil }
        return docURL.appendingPathComponent(appending)
    }
}

extension URL {
    var idExistedInDocuments: Bool {
        return FileManager.default.fileExists(atPath: self.path)
    }
}

final class GifCell: MessageCell {
    
    let imageView: UIImageView = {
        $0.isUserInteractionEnabled = true
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    override var bubbleFrame: CGRect {
        didSet {
            guard bubbleFrame != oldValue else { return }
            imageView.frame = bubbleFrame
        }
    }
    override func setup() {
        super.setup()
        contentView.addSubview(imageView)
        imageView.addInteraction(contextMenuInterAction)
    }
    
    override func configure(_ msg: Message) {
        guard self.msg?.id != msg.id else { return }
        super.configure(msg)
        if let gifURL = msg.gifURL {
            
            if gifURL.idExistedInDocuments {
                imageView.setGifFromURL(gifURL, animateAfterDownload: true)
            } else {
                _ = msg.firebaseStorageRef()?.write(toFile: gifURL) { [weak self] url, error in
                    guard let `self` = self, self.msg?.id == msg.id else { return }
                    Async.main {
                        self.imageView.setGifFromURL(gifURL, animateAfterDownload: true)
                    }
                }
            }
        }
    }
    
    override func didEndDisplayingCell() {
        super.didEndDisplayingCell()
        if isAnimatingGIF {
            isAnimatingGIF = false
        }
    }
    
    override func appearingOnScreen() {
        super.appearingOnScreen()
        if !isAnimatingGIF {
            isAnimatingGIF = true
        }
        
    }
    
    
    var isAnimatingGIF: Bool {
        get {
            return imageView.isAnimatingGif()
        }
        set {
            guard newValue != isAnimatingGIF else { return }
            newValue ? imageView.startAnimatingGif() : imageView.stopAnimatingGif()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: self)
            if bubbleFrame.contains(location) {
                SoundManager.playSound(tone: .Tock)
                isAnimatingGIF.toggle()
            }
        }
    }
   
    override func releaseObjects() {
        super.releaseObjects()
        imageView.clear()
    }
}
