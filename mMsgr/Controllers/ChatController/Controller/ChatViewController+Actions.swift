//
//  ChatViewController+Actions.swift
//  mMsgr
//
//  Created by jonahaung on 28/9/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import IQAudioRecorderController
import Photos

extension ChatViewController: AlertPresentable {
    
    
    @objc func didTapChatMenuButtonItem(_ sender: UIButton?) {
        inputBar.textView.resignFirstResponder()
        guard let room = GlobalVar.currentRoom else { return }
        let message = "\(String(describing: room.member?.phoneNumber ?? "Unknown"))\n\(String(describing: room.member?.country ?? "Unknown"))"
        let x = ChatMenuAlertController(style: .actionSheet)
        x.set(title: room.name, font: UIFont.preferredFont(forTextStyle: .headline))
        x.set(message: message, font: UIFont.preferredFont(forTextStyle: .subheadline))
        x.configure(room)
        x.show()
    }
    
    @objc func gotoFriendProfile() {
        gotoProfileController(for: GlobalVar.currentRoom?.member)
    }
    
    
    // Translae Switch
    @objc func didChangedTranslateSwitch(_ switchButton: UISwitch) {
        GlobalVar.currentRoom?.canTranslate = switchButton.isOn
        
        let text = switchButton.isOn ? "Translator On" : "Translator Off"
        dropDownMessageBar.show(text: text, duration: 5)
        if GlobalVar.currentUser?.isAdmin == true {
            MessageSender.shared.lormReply()
        }
    }
}

// Smail Controller
extension ChatViewController: SmileControllerDelegate {
    
    func smileController_didCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func smileController_didFinishDetectingSmile(hasSmile: Bool) {
        DispatchQueue.main.async {
            
            let title = hasSmile ? "Yeah! Nice smile!" : "Oops! \nYou didn't smile or your smile is not big enough"
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            if hasSmile {
                let actionOK = UIAlertAction(title: "Send this smile", style: .default) {_ in
                    MessageSender.shared.sendSmileMessage(roomID: GlobalVar.currentRoom?.objectID, text: "Smile Message", isSmile: true)
                }
                alert.addAction(actionOK)
            } else {
                let again = UIAlertAction(title: "Smile Again", style: .destructive) {_ in
                    self.inputBar(self.inputBar, performAction: .TapFace)
                }
                let cry = UIAlertAction(title: "Send this Emotion Anyway", style: .default) {_ in
                    MessageSender.shared.sendSmileMessage(roomID: GlobalVar.currentRoom?.objectID, text: "Smile Message", isSmile: false)
                }
                
                alert.addAction(cry)
                alert.addAction(again)
            }
            
            
            alert.addCancelAction()
            alert.show()
        }
    }
}


// InputBar Delegate

extension ChatViewController: InputBarDelegate {
    func inputBar_willSendText() {
        if collectionView.isScrolledAtBottom() == false {
            manager?.isCollectionViewIsScrolling = false
            collectionView.scrollToBottom(animated: false)
        }
    }
    
    
    func inputBar(_ inputBar: InputBar, performAction action: InputBar.InputBarAction) {
        
        switch action {
            
        case .KeyboardIsTyping:
            manager?.setTyping(isTyping: true)
        case .KeyboardEndsTyping:
            manager?.setTyping(isTyping: false)
            
        case .TextViewBecomesActive:

            updateCollectionViewContentInsets(shouldAdjustContentOffset: true)
        case .TextViewResignActive:
            updateCollectionViewContentInsets(shouldAdjustContentOffset: false)
            
        case .TurnOffTranslateSwitch:
            guard translateSwitch.isOn else { return }
            translateSwitch.setOn(false, animated: true)
            didChangedTranslateSwitch(translateSwitch)
        case .TapScrollBottomButton:
            inputBar.badgeStackView.showScrollButton = false
            collectionView.contentInset.bottom = bottomSpaceFromInputBar()
            collectionView.scrollToBottom(animated: true)
        case .TapPhotoButton:
            
            _ = PresentPhotoLibrary(target: self, edit: true)
            
        case  .TapVideosButton:
            
            _ = PresentVideoLibrary(target: self, edit: true)
            
        case .TapPhotoCamera:
            MediaPicker_OpenCamera(.PhotoCamera)
        case .TapVideoCamera:
            MediaPicker_OpenCamera(.VideoCamera)
        case  .TapFace:
            
            let smileController = SmaileController()
            smileController.delegate = self
            self.present(smileController, animated: true, completion: nil)
            
        case  .TapMicrophone:
            
            let audio = Audio(delegate_: self)
            audio.presentAudioRecorder(target: self)
        }
    }
    
}


// Audio Recorder Delegate

extension ChatViewController: IQAudioRecorderViewControllerDelegate {
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        let url = URL(fileURLWithPath: filePath)
        print(url)
        controller.dismiss(animated: true) {[weak self] in
            guard let `self` = self else { return }
            self.collectionView.becomeFirstResponder()
            self.updateCollectionViewContentInsets(shouldAdjustContentOffset: true)
            MessageSender.shared.sendAudioMessage(roomID: GlobalVar.currentRoom?.objectID, url: url)
        }
        
    }
}

// Image Picker
extension ChatViewController {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {[weak self] in
            guard let `self` = self else { return }
            self.collectionView.becomeFirstResponder()
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {[weak self] in
            guard let `self` = self else { return }
            self.collectionView.becomeFirstResponder()
            if let image = info[.originalImage] as? UIImage {
                MessageSender.shared.sendPhotoMessage(roomID: GlobalVar.currentRoom?.objectID, image: image)
            }else if let videoURL = info[.mediaURL] as? URL {
                MessageSender.shared.sendVideoMessage(roomID: GlobalVar.currentRoom?.objectID, url: videoURL)
            }
        }
    }
}
