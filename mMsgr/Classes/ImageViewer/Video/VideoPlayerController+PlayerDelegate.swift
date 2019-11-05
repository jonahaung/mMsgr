//
//  VideoPlayerController+PlayerDelegate.swift
//  mMsgr
//
//  Created by jonahaung on 18/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Foundation

extension VideoPlayerController: PlayerDelegate {
    
    func playerReady(_ player: Player) {
        playButton.isEnabled = false
        pauseButton.isEnabled = true
        rewindButton.isEnabled = true
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        switch (player.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue:
            playButton.isEnabled = true
            pauseButton.isEnabled = false
            rewindButton.isEnabled = false
            break
        case PlaybackState.paused.rawValue:
            playButton.isEnabled = true
            pauseButton.isEnabled = false
            rewindButton.isEnabled = false
            break
        case PlaybackState.playing.rawValue:
            playButton.isEnabled = false
            pauseButton.isEnabled = true
            rewindButton.isEnabled = true
            break
        case PlaybackState.failed.rawValue:
            playButton.isEnabled = false
            pauseButton.isEnabled = false
            rewindButton.isEnabled = false
            break
        default:
            break
        }
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        print("buffer")
    }
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        mySlider.minimumValue = 0
        mySlider.maximumValue = Float(bufferTime)
    }
    
}

// MARK: - PlayerPlaybackDelegate

extension VideoPlayerController: PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
        let value = Float(player.currentTime)
        mySlider.value = value
        
        if !initialPlayCompleted {
            if value.rounded() == 2 {
                initialPlayCompleted = true
                handleTapGestureRecognizer()
            }
        }
        
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        
    }
}
