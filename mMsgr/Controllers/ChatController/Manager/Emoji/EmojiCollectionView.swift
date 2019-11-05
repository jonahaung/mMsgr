//
//  EmojiCollectionView.swift
//  mMsgr
//
//  Created by jonahaung on 28/9/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import FirebaseStorage

protocol EmojiManagerDelegate: class {
    func emojiManagerr(manager: EmojiManager, didSelect emojiURL: URL, emojiSize: CGSize)
    func emojiManagerr(emojiManagerDidCancel manager: EmojiManager)
}

class EmojiManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    weak var delegate: EmojiManagerDelegate?
    
    let collectionView = EmojiCollectionView()
    private let urls: [URL] = {
        
        var urls = [URL]()
        
        for i in 1...17 {
            
            let fileName = "\(i).gif"
            urls.append(docURL.appendingPathComponent(fileName))
        }
        return urls
    }()
    
    override init() {
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let swipeDownGesture = UISwipeGestureRecognizer()
        swipeDownGesture.direction = .down
        swipeDownGesture.addTarget(self, action: #selector(swipeDown))
        collectionView.addGestureRecognizer(swipeDownGesture)
    }
    
    @objc private func swipeDown() {
        delegate?.emojiManagerr(emojiManagerDidCancel: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.superview == nil ? 0 : urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let url = urls[indexPath.item]
        
        let cell: EmojiCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.loadEmoji(url: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        vibrate(vibration: .medium)
         
        guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
        
        let url = urls[indexPath.item]
        
        if let image = cell.imageView.currentImage {
            let size = image.size
            let oldWidth = size.width
            
            var maxWidth = GlobalVar.vSCREEN_WIDTH * 0.7
            maxWidth = oldWidth/2 > maxWidth ? maxWidth : oldWidth/2
            
            let scaleFactor = maxWidth / oldWidth
            
            let newHeight = size.height * scaleFactor
            let newWidth = oldWidth * scaleFactor
            
            let newSize = CGSize(width:newWidth, height:newHeight)
            SoundManager.playSound(tone: .Tock)
            cell.animateCellSelect({
                self.delegate?.emojiManagerr(manager: self, didSelect: url, emojiSize: newSize)
            })
        }
    }
}

class EmojiCollectionView: UICollectionView {
    
    private var itemSize = CGSize(width: 80, height: 80)
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: ScreenSize.width - contentInset.horizontal, height: (itemSize.height * 3) + contentInset.vertical)
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = itemSize
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        super.init(frame: .zero, collectionViewLayout: layout)
        setup()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Setup
    private func setup() {
        bounces = true
        alwaysBounceHorizontal = true
        showsHorizontalScrollIndicator = false
        setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        register(EmojiCell.self)
    }
}

final class EmojiCell: CollectionViewCell {
    
    let imageView: UIImageView = { x in
        return x
    }(UIImageView())

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.clear()
    }
    
    override func setup() {
        super.setup()
        contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        imageView.roundedShadow()
    }
    
    func loadEmoji(url: URL){
        if FileManager().fileExists(atPath: url.path) {
            self.imageView.setGifFromURL(url)
            self.imageView.startAnimatingGif()
        } else {
            
            let ref = Storage.storageference(for: url.lastPathComponent, type: .Gif)
            ref.write(toFile: url) { [weak self] url, error in
                guard let `self` = self else { return }
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            
                DispatchQueue.main.safeAsync {
                    self.imageView.setGifFromURL(url)
                    self.imageView.startAnimatingGif()
                }
            }
        }
    }
}
