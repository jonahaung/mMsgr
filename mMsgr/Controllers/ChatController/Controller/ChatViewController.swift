//
//  ChatViewController.swift
//  mMsgr
//
//  Created by jonahaung on 2/6/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//
//var mMsgr_translateModeOn = false


import UIKit

final class ChatViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MediaPicker, MainCoordinatorDelegatee {
    
    var didLayoutSubviews = false
    var accessoryViewRevealer: AccessoryViewRevealer? = nil
    var navigationTitleView: ChatNavigationTitleView? {
        return navigationItem.titleView as? ChatNavigationTitleView
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    override var inputAccessoryView: UIView? { return inputBar }
    let inputBar = InputBar()
    
    let collectionView = ChatCollectionView(frame: UIScreen.main.bounds, collectionViewLayout: ChatCollectionViewLayout())
    
    
    let timeLabel = TimeLabel(frame: .zero)
    let translateSwitch: SwitchBUtton = {
        $0.thumbTintColor = GlobalVar.theme.mainColor
        return $0
    }(SwitchBUtton())
    
    var manager: ChatManager?
    
    let avatar: BadgeAvatarImageView = {
        $0.badgeColor = GlobalVar.theme.mainColor
        return $0
    }(BadgeAvatarImageView())
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupChatManager()
        setupAccessoryViewRevealer()
        
    }
   
    // Did Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubviews {
            adjustInsetsToSafeArea()
            collectionView.scrollToBottom(animated: false) {
                self.didLayoutSubviews = true
                self.adjustInsetsToSafeArea()
                self.layoutTimeLabel()
            }
        }
        
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let hasFontChanges = previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        if hasFontChanges {

            (collectionView.collectionViewLayout as? ChatCollectionViewLayout)?.sizingFactory.clearCaches()
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            collectionView.collectionViewLayout.invalidateLayout()
            adjustInsetsToSafeArea()
        }
        
        if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) == true {
            collectionView.setBackgroundImage()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager?.viewDid(appear: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputBar.superViewDidAppear()
        
        
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        manager?.viewDid(appear: false)
    }
    
    func layoutTimeLabel() {
        guard !timeLabel.isHidden else { return }
        timeLabel.center.y = view.safeAreaInsets.top + 15
    }
    
    deinit {
       
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        assetFactory.clearCaches()
        print("DEINIT: ChatViewController")
    }
}
