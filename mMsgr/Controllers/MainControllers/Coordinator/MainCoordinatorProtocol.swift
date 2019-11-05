//
//  MainCoordinatorProtocol.swift
//  mMsgr
//
//  Created by Aung Ko Min on 5/6/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

protocol MainCoordinatorDelegatee {
    
    var maincoordinator: MainCoordinator? { get }
    func gotoChatLogController(for room: Room)
    func gotoProfileController(for frind: Friend?)
    func gotoMediaGalleryController(room: Room, msgType: MsgType)
    func showImageViewer(image: UIImage, fromView: UIView, originalURL: URL?, localURL: URL?)
    func showVideoViewer(for url: URL?)
    func showAudioPlayer(for url: URL?)
    func showMediaViewer(for msg: Message?, from imageView: UIImageView?)
}

extension MainCoordinatorDelegatee {
    
    var maincoordinator: MainCoordinator? {
       
        return AppDelegate.sharedInstance.mainCoordinator
    }
    
    var chatViewController: ChatViewController? {
        return maincoordinator?.navigationController.visibleViewController as? ChatViewController
    }
    
    func gotoChatLogController(for room: Room) {
        GlobalVar.currentRoom = room
        maincoordinator?.pushViewController(ChatViewController())
    }
    
    func gotoProfileController(for friend: Friend?) {
        guard let friend = friend, friend.isFriend else {
            return
        }
        let x = FriendProfileController()
        x.friend = friend
        maincoordinator?.pushViewController(x)
    }
    
    func gotoMediaGalleryController(room: Room, msgType: MsgType) {
        let x = MediaGalleryController()
        x.msgType = msgType
        x.room = room
        maincoordinator?.pushViewController(x)
    }
    
    func showImageViewer(image: UIImage, fromView: UIView, originalURL: URL?, localURL: URL?) {
        let imageInfo   = GSImageInfo(image: image, imageMode: .aspectFit, originalURL: originalURL, localURL: localURL)
        let transitionInfo = GSTransitionInfo(fromView: fromView)
        let x = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        maincoordinator?.presentViewController(x)
    }
    
    
    func showVideoViewer(for url: URL?) {
        let vc = VideoPlayerController()
        vc.videoUrl = url                                                                                
        vc.isAudio = false
        maincoordinator?.presentViewController(UINavigationController(rootViewController: vc))
    }
    
    func showAudioPlayer(for url: URL?) {
        let vc = VideoPlayerController()
        vc.videoUrl = url
        vc.isAudio = true
        maincoordinator?.presentViewController(UINavigationController(rootViewController: vc))
    }
    
    func showMediaViewer(for msg: Message?, from imageView: UIImageView?) {
        
        guard let msg = msg, let url = msg.mediaURL else { return }
        let type = msg.messageType
        
        switch type {
        case .Photo:
            if let image = UIImage(contentsOfFile: url.path), let imageView = imageView {
                showImageViewer(image: image, fromView: imageView, originalURL: nil, localURL: nil)
            }
        case .Video:
            showVideoViewer(for: url)
        case .Audio:
            showAudioPlayer(for: url)
        case .Gif:
            if imageView?.isAnimatingGif() == true {
                imageView?.stopAnimatingGif()
            } else {
                imageView?.startAnimatingGif()
            }
        default:
            break
        }
    }
    
}
