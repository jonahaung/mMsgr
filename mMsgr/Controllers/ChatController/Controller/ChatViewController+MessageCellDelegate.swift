//
//  ChatViewController+MessageCellDelegate.swift
//  mMsgr
//
//  Created by jonahaung on 24/7/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import MessageUI
extension ChatViewController: ChatManagerDelegate {
    
    func chatManager(scrollToBottom manager: ChatManager) {
        guard manager.isCollectionViewIsScrolling == false else { return }
        manager.isCollectionViewIsScrolling = true
        collectionView.contentInset.bottom = self.bottomSpaceFromInputBar()
        collectionView.scrollToBottom(animated: true)
    }
    
    func chatManager(_ manager: ChatManager, didUpdateFriendURL urlString: String?) {
       
        if let room = GlobalVar.currentRoom, let friend = room.member {
            avatar.loadImage(for: friend, refresh: true)
        }
    }
    
    func chatManager(_ manager: ChatManager, shouldUpdateTime time: String?) {
        if !timeLabel.isHidden {
            timeLabel.text = time
        }
    }
    
    func chatManager(_ manager: ChatManager, scrollViewIsScrolling isScrolling: Bool) {
        accessoryViewRevealer?.canPerformGesture = !isScrolling
        if isScrolling && collectionView.isSafeToInteract && inputBar.textView.isFirstResponder {
            inputBar.textView.resignFirstResponder()
        } else {
            inputBar.badgeStackView.showScrollButton = !collectionView.isCloseToBottom()
        }
        timeLabel.isHidden = !isScrolling
    }
    func chatManager(_ manager: ChatManager, didUpdateUserActivity activity: UserActivity) {

        let isOnline = activity.isOnline
        let isTyping = activity.isTyping
        let isFocused = activity.isFocused
        
        navigationTitleView?.subtitle = isFocused ? isOnline ? "Focused" : "Background" : isOnline ? "Online" : activity.lastSeenDate.forChatMessage()

        let color = isOnline ? UIColor.myappGreen : UIColor.systemRed
        avatar.badgeColor = color
            
        inputBar.badgeStackView.isTyping = isTyping
        
        GlobalVar.currentRoom?.member?.lastAccessedDate = activity.lastSeenDate
    }
}
extension ChatViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [unowned dropDownMessageBar] in
            dropDownMessageBar.show(text: "Thank you for Reporting us. We will look into it and get back to you soon !", duration: 4)
        }
    }
}
