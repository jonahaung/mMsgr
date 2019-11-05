//
//  RichLinkCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 16/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import LinkPresentation

final class RichLinkCell: MessageCell {
    
    private(set) weak var linkView: LPLinkView?
    
    let progressView = UIActivityIndicatorView(style: .large)
    
    override var bubbleFrame: CGRect {
        didSet {
            guard bubbleFrame != oldValue else { return }
            
            progressView.frame = bubbleFrame
            linkView?.frame = bubbleFrame
        }
    }
    override func setup() {
        super.setup()
        
        let menuImage = MessageCell.menuImageRichLinkCell
        menuImageView.image = menuImage
        
        progressView.sizeToFit()
        contentView.addSubview(progressView)
        
    }
    
    
    private func createLPLinkView(_ meta: LPLinkMetadata) {
        linkView?.removeFromSuperview()
        linkView = nil
        
        let linkView = LPLinkView(metadata: meta)
        linkView.frame = bubbleFrame
        contentView.addSubview(linkView)
        linkView.sizeToFit()
        linkView.frame = linkView.sizeThatFits(bubbleFrame.size).bma_rect(inContainer: bubbleFrame, xAlignament: .center, yAlignment: .center)
        self.linkView = linkView
        progressView.stopAnimating()
    }
    override func configure(_ msg: Message) {
        guard self.msg?.id != msg.id else { return }
        super.configure(msg)
        let id = msg.id
        progressView.startAnimating()

        if let url = URL(string: msg.text) {
            
            if let meta = msg.getRichLinkMetadata() {
                createLPLinkView(meta)
                return
            }
            
            msg.retriveRichLinkMetadata(url) { [weak self] (meta) in
                guard let `self` = self, self.msg?.id == id else { return }
                if let meta = meta {
                    self.createLPLinkView(meta)
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        msg = nil
        linkView?.removeFromSuperview()
        linkView = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: self)
            if menuImageView.frame.contains(location) {
                vibrate(vibration: .light)
                menuImageView.animatePressedFade { [weak self] _ in
                    
                    guard let `self` = self else { return }
                    
                    let alert = UIAlertController(style: .actionSheet)
                    if let url = self.linkView?.metadata.originalURL {
                        alert.addAction(image: UIImage(systemName: "arrowshape.turn.up.right.fill"), title: "Share") {_ in        url .shareWithMenu()
                           
                        }
                    }
                    
                    alert.addAction(image: UIImage(systemName: "trash.fill"), title: "Delete") { _ in
                        self.msg?.delete()
                    }
                    alert.addCancelAction()
                    alert.show()
                }
            }
        }
    }
}
