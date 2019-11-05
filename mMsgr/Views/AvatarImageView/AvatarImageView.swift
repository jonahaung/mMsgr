//
//  AvatarImageView.swift
//  mMsgr
//
//  Created by jonahaung on 10/8/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

//
//  UIImageView+Cache.swift
//  streamapp
//
//  Created by Brian Voong on 7/29/16.
//  Copyright © 2016 luxeradio. All rights reserved.
//
import UIKit
import FirebaseStorage
import FirebaseAuth

class AvatarImageView: UIView, MainCoordinatorDelegatee {
    
    let imageView = UIImageView()
    private var activityIndicator: UIActivityIndicatorView = {
        $0.hidesWhenStopped = true
        return $0
    }(UIActivityIndicatorView())
    
    private lazy var storageRef = Storage.storage().reference().child(StorageDirectory.ProfilePhoto.rawValue)
    var currentId: String?
    private var currentURL: URL?
    private var currentDownloadingSession: URLSessionDataTask?
    
    var diameter: CGFloat = 35 {
        didSet {
            size = CGSize(diameter)
        }
    }
    
    var currentImage: UIImage? {
        get {
            return imageView.image
        }
        set {
            if newValue == nil {
                if !activityIndicator.isAnimating {
                    activityIndicator.startAnimating()
                }
            } else {
                if activityIndicator.isAnimating {
                    activityIndicator.stopAnimating()
                }
            }
            imageView.image = newValue
            
        }
    }
    
    var padding = CGFloat(0)
    var backColor: UIColor? {
        didSet {
            guard backColor != oldValue else { return }
            backgroundColor = backColor
        }
    }

    init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(diameter)))
        setup()
    }
    
    
    func setup() {
        addSubview(imageView)
        addSubview(activityIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds.inset(by: .init(round: padding))
        activityIndicator.center = bounds.center
        if padding > 0 {
            layer.cornerRadius = bounds.height/2
        }
    }
    
    func prepareForReuse() {
        currentId = nil
        currentImage = nil
        currentURL = nil
        currentDownloadingSession?.cancel()
        currentDownloadingSession = nil
    }
    
    func loadImage(for friend: Friend, refresh: Bool) {
        if refresh {
            prepareForReuse()
        }
        let localURL = friend.photoURL_local
        if currentId == friend.uid &&  self.currentImage != nil { return }
        currentId = friend.uid
        currentImage = nil
        
        guard let remoteURL = friend.photoURL else {
            getRemoteURL(for: friend)
            return
        }
        
        if !refresh, let storedImage = UIImage(contentsOfFile: localURL.path) {
            currentImage = storedImage
            return
        }
    
        downloadAndSetImage(for: remoteURL, localURL: localURL)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AvatarImageView {
    
    private func getRemoteURL(for friend: Friend) {
        if self.currentId != friend.uid { return }
        let fileName = friend.uid+DataType.JPG.rawValue
        storageRef.child(fileName).downloadURL { [weak self] (x, err) in
            guard let `self` = self else { return }
            if self.currentId != friend.uid { return }
            if let err = err {
                print(err)
            }
            
            let remoteURL = x ?? URL(string: "https://i.pravatar.cc/300")!
            friend.photoURL = remoteURL
            friend.managedObjectContext?.save(shouldPropagate: true, callback: {[weak self] (_) in
                guard let `self` = self else { return }
                if self.currentId != friend.uid { return }
                self.loadImage(for: friend, refresh: false)
            })
        }
    }
    
    private func downloadAndSetImage(for remoteURL: URL, localURL: URL) {
        if currentURL == remoteURL { return }
        currentURL = remoteURL
        currentDownloadingSession?.cancel()
        currentDownloadingSession = URLSession(configuration: .default).dataTask(with: remoteURL) {[weak self] (data, response, err) in
            guard let `self` = self else { return }
            if self.currentURL != remoteURL { return }
            if let err = err {
                print(err)
                return
            }
            
            guard let data = data, let image = UIImage(data: data)?.EXT_circleMasked, let circleImageData = image.png else { return }
            do {
                try circleImageData.write(to: localURL)
                Async.main {
                    if self.currentURL != remoteURL { return }
                    self.currentImage = image
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        currentDownloadingSession?.resume()
        
    }
}
// Current User
extension AvatarImageView {
    func loadImageForCurrentUser(refresh: Bool) {
        guard let user = Auth.auth().currentUser else { return }
        if refresh { prepareForReuse() }
        if currentId == user.uid &&  self.currentImage != nil { return }
        currentId = user.uid
        if let remoteURL = user.photoURL {
            let localURL = user.photoURL_local
            
            if !refresh, let storedImage = UIImage(contentsOfFile: localURL.path) {
                currentImage = storedImage
                return
            }
            downloadAndSetImage(for: remoteURL, localURL: localURL)
        }
    }
}

extension AvatarImageView {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let first = touches.first {
            self.didTap(first)
            
        }
        
    }
    
    @objc private func didTap(_ touch: UITouch?) {
        if let id = self.currentId, let friend = Friend.findOrFetch(in: PersistenceManager.sharedInstance.viewContext, predicate: Friend.predicate(forUID: id)) {
            let alert = UIAlertController(style: .actionSheet)
            
            alert.set(title: friend.displayName, font: UIFont.preferredFont(forTextStyle: .headline))
            alert.set(message: friend.phoneNumber, font: UIFont.preferredFont(forTextStyle: .subheadline))
            
            alert.addAction(image: nil, title: "\(friend.displayName.firstWord)'s Profile", color: nil, style: .default, isEnabled: id != GlobalVar.currentUser?.uid) { _ in
                self.gotoProfileController(for: friend)
            }
            
            if let url = friend.photoURL, let image = self.currentImage {
                let localURL = friend.photoURL_local
                alert.addAction(image: nil, title: "View Photo", color: nil, style: .default, isEnabled: true) { _ in
                    self.showImageViewer(image: image, fromView: self, originalURL: url, localURL: localURL)
                }
            }
            
            
            alert.addCancelAction()
            alert.show()
        }else {
            if let image = self.currentImage {
                showImageViewer(image: image, fromView: self, originalURL: nil, localURL: nil)
            }
        }
    }
    
    func showMediaViewer() {
        guard let image = currentImage, let id = self.currentId else { return }
        let url = docURL.appendingPathComponent(id)
        showImageViewer(image: image, fromView: self, originalURL: url, localURL: url)
    }
    
}
