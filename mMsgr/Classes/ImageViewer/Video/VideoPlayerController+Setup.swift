//
//  VideoPlayerController+Setup.swift
//  mMsgr
//
//  Created by jonahaung on 18/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import AVFoundation
// Setup

extension VideoPlayerController {
    
    
    func setupSlider() {
        mySlider.addTarget(self, action: #selector(VideoPlayerController.sliderValueDidChange(_:)), for: .valueChanged)
        view.addSubview(mySlider)
        mySlider.addConstraints(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 5, rightConstant: 10, widthConstant: 0, heightConstant: 0)
    }
    
    
    func setupToolbar() {
        playButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(handlePlay))
        pauseButton = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(handlePause))
        rewindButton = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(handleRewind))
        let exit = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        if let toolBar = navigationController?.toolbar {
            toolBar.cler()
            toolBar.backgroundColor = UIColor.black
    
            toolBar.barTintColor = UIColor.clear
            toolBar.barStyle = .black
            toolBar.tintColor = UIColor.myAppYellow
            toolbarItems = [playButton, UIBarButtonItem.space(), rewindButton, UIBarButtonItem.space(), pauseButton, UIBarButtonItem.space(), exit]
        }
        
        navigationController?.setToolbarHidden(false, animated: false)
        
    }
    
    func setupPlayer() {
        addChild(self.player)
        view.addSubview(player.view)
        player.view.fillSuperview()
    
        player.didMove(toParent: self)
        
        player.url = videoUrl
        player.fillMode = PlayerFillMode.resizeAspectFit.avFoundationType
        player.playbackLoops = false
    }
    
    func setupGestures() {
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        player.view.addGestureRecognizer(tapGestureRecognizer)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer(_:)))
        swipe.direction = .down
        player.view.addGestureRecognizer(swipe)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        player.view.addGestureRecognizer(pan)
    }
}


// Handlers

extension VideoPlayerController {
    
    @objc fileprivate func handlePlay() {
        
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue:
            self.player.playFromBeginning()
            break
        case PlaybackState.paused.rawValue:
            self.player.playFromCurrentTime()
            break
        default:
            break
        }
    }
    
    // Slider
    
    @objc func sliderValueDidChange(_ sender: UISlider!){
        player.pause()
        let newTime = CMTimeMakeWithSeconds(Float64(sender.value), preferredTimescale: 1)
        player.seek(to: newTime) { [weak self] done in
            if done == true {
                self?.player.playFromCurrentTime()
            }
        }
    }
    
    @objc fileprivate func handleRewind() {
        self.player.playFromBeginning()
    }
    
    @objc fileprivate func handlePause() {
        self.player.pause()
    }
    
    @objc fileprivate func handleDone() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.player.pause()
        dismiss(animated: true, completion: nil)
    }
}

// Gestures

// MARK: - UIGestureRecognizer

extension VideoPlayerController {
    
    // Tap
    @objc func handleTapGestureRecognizer() {
        if let toolBar = navigationController?.toolbar {
            let toolbarIsHideen = toolBar.isHidden
            navigationController?.setToolbarHidden(!toolbarIsHideen, animated: true)
            mySlider.isHidden = !toolbarIsHideen
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    // Swipe
    @objc fileprivate func handleSwipeGestureRecognizer(_ gesture: UISwipeGestureRecognizer) {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue:
            dismiss(animated: true, completion: nil)
            break
        case PlaybackState.paused.rawValue:
            dismiss(animated: true, completion: nil)
            break
        case PlaybackState.playing.rawValue:
            self.player.pause()
            dismiss(animated: true, completion: nil)
            break
        case PlaybackState.failed.rawValue:
            self.player.pause()
            dismiss(animated: true, completion: nil)
            break
        default:
            self.player.pause()
            break
        }
    }
    
    // Pan
    
    @objc fileprivate func pan(_ gesture: UIPanGestureRecognizer) {
        
        func getProgress() -> CGFloat {
            let origin = panViewOrigin!
            let changeX = abs(player.view.center.x - origin.x)
            let changeY = abs(player.view.center.y - origin.y)
            let progressX = changeX / view.bounds.width
            let progressY = changeY / view.bounds.height
            return max(progressX, progressY)
        }
        
        func getChanged() -> CGPoint {
            let origin = player.view.center
            let change = gesture.translation(in: view)
            return CGPoint(x: origin.x + change.x, y: origin.y + change.y)
        }
        
        func getVelocity() -> CGFloat {
            let vel = gesture.velocity(in: player.view)
            return sqrt(vel.x*vel.x + vel.y*vel.y)
        }
        
        switch gesture.state {
            
        case .began:
            
            panViewOrigin = player.view.center
            
        case .changed:
            
            player.view.center = getChanged()
        
            gesture.setTranslation(CGPoint.zero, in: nil)
            
        case .ended:
            
            if getProgress() > 0.25 || getVelocity() > 1000 {
                dismiss(animated: true, completion: dismissCompletion)
            } else {
                fallthrough
            }
            
        default:
            
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.player.view.center = self.panViewOrigin!
            
            },
                           completion: { _ in
                            self.panViewOrigin = nil
                        
            }
            )
            
        }
    }
    
}
