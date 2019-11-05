//
//  ChatViewController+Setup.swift
//  mMsgr
//
//  Created by jonahaung on 30/6/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit

extension ChatViewController {
    
    // Navigation Item
    func setupViews() {
        navigationController?.navigationBar.tintColor = GlobalVar.theme.mainColor
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.titleView = ChatNavigationTitleView()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: avatar)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: translateSwitch),
            UIBarButtonItem(image: UIImage.systemImage(name: "equal", pointSize: 20, symbolWeight: .bold), style: .done, target: self, action: #selector(didTapChatMenuButtonItem(_:)))
        ]
        
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
        view.addSubview(timeLabel)
         
        inputBar.inputBarDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        
    }
    
    // Datasource
    func setupChatManager() {
        if let room = GlobalVar.currentRoom {
            
            navigationTitleView?.titleLabel.text = room.name
            
            
            if let friend = room.member {
                avatar.loadImage(for: friend, refresh: false)
            }
            manager = ChatManager(_room: room, _collectionView: collectionView)
            manager?.delegate = self
            
            translateSwitch.isOn = room.canTranslate == true
            translateSwitch.addTarget(self, action: #selector(ChatViewController.didChangedTranslateSwitch(_:)), for: .valueChanged)
            avatar.action({ [weak self] _ in
                SoundManager.playSound(tone: .Tock)
                self?.gotoFriendProfile()
            })
            
            navigationTitleView?.action { [weak self] _ in
                self?.gotoFriendProfile()
            }
        }
        
    }
    
    // AccessoryViewRevealer
    func setupAccessoryViewRevealer() {
        accessoryViewRevealer = AccessoryViewRevealer(_collectionView: collectionView)
    }

}
