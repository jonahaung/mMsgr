//
//  PhotoVideoCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 20/6/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import FirebaseStorage

final class PhotoVideoCell: MessageCell {
    
    let imageView: UIImageView = {
        $0.isUserInteractionEnabled = true
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        return $0
    }(UIImageView())
    let progressView = UIActivityIndicatorView(style: .large)
    
    private(set) weak var image: UIImage? {
        didSet {
            
            imageView.image = image
            if image == nil {
                if !progressView.isAnimating {
                    progressView.startAnimating()
                }
            } else {
                if progressView.isAnimating {
                    progressView.stopAnimating()
                }
            }
        }
    }
    
    override var bubbleFrame: CGRect {
        didSet {
            guard bubbleFrame != oldValue else { return }
            imageView.frame = bubbleFrame
            progressView.center = imageView.bounds.center
        }
    }
    
    override func setup() {
        
        super.setup()
    
        menuImageView.image = MessageCell.menuImagePhotoVideoCell
        menuImageView.sizeToFit()
        
        
        contentView.addSubview(imageView)
        imageView.addSubview(progressView)
        imageView.addInteraction(contextMenuInterAction)
    }
    
    
    private var task: StorageDownloadTask?
    
    override func configure(_ msg: Message) {
        guard self.msg?.id != msg.id else { return }
        super.configure(msg)
        let id = msg
        image = nil
        getImage(for: msg) {[weak self] (image) in
            guard let `self` = self, self.msg == id else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    //    override func configure(_ msg: Message, _ assetFactory: ChatAssetFactory?)  {
    //        guard msg.id != msgId else { return }
    //        super.configure(msg, assetFactory)
    //        if !progressView.isAnimating {
    //            progressView.startAnimating()
    //        }
    //
    //        self.imageView.image = nil
    //        let id = msg.id
    //        var media: UIImage?
    //        let width = imageView.bounds.width
    //        Async.background{[weak self, weak msg, weak assetFactory] in
    //            guard let `self` = self, let msg = msg, let assetFactory = assetFactory, self.msgId == id else { return }
    //            if let image = assetFactory.image(for: id) {
    //                media = image
    //                return
    //            }
    //
    //            guard let localUrl = msg.mediaURL else { return }
    //            if let original = UIImage(contentsOfFile: localUrl.path), let image = original.photoMessageThumbnil(to: width){
    //                assetFactory.setImage(for: id, image: image)
    //                media = image
    //                return
    //            }else if let image = localUrl.getVideoThumbnail() {
    //                assetFactory.setImage(for: id, image: image)
    //                media = image
    //                return
    //            }
    //
    //            if self.task != nil {
    //                self.task?.resume()
    //                return
    //            }
    //
    //            // Download
    //
    //            guard !self.isSender, let storageReference = msg.firebaseStorageRef() else { return }
    //
    //            self.task = storageReference.write(toFile: localUrl) { [weak self, weak msg, unowned storageReference] url, error in
    //                guard let self = self, self.msgId == id, let msg = msg else { return }
    //                if let error = error {
    //                    print(error.localizedDescription)
    //                    return
    //                }
    //
    //
    //                storageReference.delete(completion: nil)
    //
    //                Async.main{
    //                    self.msgId = nil
    //                    self.configure(msg, assetFactory)
    //                }
    //            }
    //        }.main{
    //            guard id == self.msgId, let image = media else { return }
    //            self.imageView.image = image
    //            self.progressView.stopAnimating()
    //        }
    //    }
    
    private func getImage(for msg: Message, completion: @escaping (UIImage?) -> Void ) {
        
        Async.background{
            if let image = assetFactory.image(for: msg.id) {
                completion(image)
                return
            }
            
            guard let localUrl = msg.mediaURL else {
                completion(nil)
                return
            }
            if let original = UIImage(contentsOfFile: localUrl.path), let image = original.photoMessageThumbnil(to: CGFloat(msg.x)){
                assetFactory.setImage(for: msg.id, image: image)
                completion(image)
                return
            }
            
            if let image = localUrl.getVideoThumbnail() {
                assetFactory.setImage(for: msg.id, image: image)
                completion(image)
                return
            }
            
    
            // Download
            
            if msg.isSender {
                completion(nil)
                msg.delete()
                return
            }
            if self.task != nil {
                self.task?.resume()
                completion(nil)
                return
            }
            guard let storageReference = msg.firebaseStorageRef() else {
                completion(nil)
                return
            }
            
            self.task = storageReference.write(toFile: localUrl) { [weak self, weak msg, unowned storageReference] url, error in
                guard let self = self, let msg = msg, self.msg?.id == msg.id else {
                    completion(nil)
                    return
                }
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil)
                    msg.delete()
                    return
                }
                
                
                storageReference.delete(completion: nil)
                
                Async.main{
                    completion(nil)
                    self.msg = nil
                    self.configure(msg)
                    
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: self)
            if bubbleFrame.contains(location) {
                vibrate(vibration: .light)
                guard let msg = self.msg else { return }
                self.showMediaViewer(for: msg, from: imageView)
            } else if menuImageView.frame.contains(location) {
                vibrate(vibration: .light)
                menuImageView.animatePressedFade { [weak self] _ in
                    
                    guard let `self` = self else { return }
                    
                    let alert = UIAlertController(style: .actionSheet)
                    
                    alert.addAction(image: UIImage(systemName: "tray.and.arrow.down.fill"), title: "Save to Device Album", color: UIColor.myappGreen, style: .default, isEnabled: true) { [weak self] _ in
                        
                        guard let `self` = self else { return }
                        
                        if let msg = self.msg {
                            if let url = msg.mediaURL, let image = UIImage(contentsOfFile: url.path) {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            }
                        }
                        
                    }
                    
                    alert.addCancelAction()
                    alert.show()
                }
                
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
    }
    
    override func releaseObjects() {
        super.releaseObjects()
        task?.cancel()
    }
}

