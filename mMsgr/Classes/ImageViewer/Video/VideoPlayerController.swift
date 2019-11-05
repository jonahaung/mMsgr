//
//  VideoPlayerController.swift
//  mMsgr
//
//  Created by jonahaung on 18/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

class VideoPlayerController: UIViewController {
    
    var videoUrl: URL!
    var playButton: UIBarButtonItem!
    var pauseButton: UIBarButtonItem!
    var rewindButton: UIBarButtonItem!
    
    var initialPlayCompleted = false
    
    var isAudio: Bool = false
    
    let mySlider: UISlider = {
        let x = UISlider()
        x.isContinuous = true
        x.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        x.tintColor = UIColor.myAppYellow
        return x
    }()
    
    var panViewOrigin : CGPoint?

    var dismissCompletion: (() -> Void)?
    
    lazy var player: Player = {
        let x = Player()
        x.playerDelegate = self
        x.playbackDelegate = self
        return x
    }()
    
    // MARK: object lifecycle
    deinit {
        self.player.willMove(toParent: self)
        self.player.view.removeFromSuperview()
        self.player.removeFromParent()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupToolbar()
        setupPlayer()
        setupSlider()
        setupGestures()
        if isAudio {
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 200)))
            imageView.image = #imageLiteral(resourceName: "PlayButton")
            imageView.clipsToBounds = true
            player.view.addSubview(imageView)
            imageView.centerInSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.player.playFromBeginning()
        navigationController?.setToolbarHidden(false, animated: true)
    }
}


