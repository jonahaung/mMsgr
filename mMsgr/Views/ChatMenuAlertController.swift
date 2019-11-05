//
//  ChatMenuAlertController.swift
//  mMsgr
//
//  Created by Aung Ko Min on 8/3/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import MessageUI

final class ChatMenuAlertController: UIAlertController, MainCoordinatorDelegatee, AlertPresentable {
    
    var room: Room?

    func configure(_ room: Room?) {
        self.room = room
        guard let room = self.room else { return }
        guard let friend = room.member else { return  }
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        
        addAction(image: UIImage(systemName: "person.crop.square.fill", withConfiguration: config), title: "Go to \(friend.displayName.firstWord)'s Profile") {  [weak self] _ in
            self?.gotoProfileController(for: friend)
        }
        
       
        addAction(image: UIImage(systemName: "arrowshape.turn.up.right.fill", withConfiguration: config), title: "Share This Screenshot") {  _ in
            if let image = AppDelegate.sharedInstance.window?.asImage() {
                image.shareWithMenu()
            }
        }
        
        addAction(image: UIImage(systemName: "trash.slash.fill", withConfiguration: config), title: "Clear All Messages") {  [weak self] _ in
            self?.AlertPresentable_showAlert(buttonText: "Continue", message: "All the messages will be deleted and you'll no longer be able to recover them.", cancelButton: true, style: .destructive, completion: { agree in
                if agree {
                    
                    GlobalVar.currentRoom = nil
                    UIApplication.topViewController()?.navigationController?.popViewControler(animated: true, completion: {
                        let context = PersistenceManager.sharedInstance.editorContext
                        context.performAndWait {
                            let rm = context.object(with: room.objectID)
                            context.delete(rm)
                            context.saveIfHasChnages()
                        }
                    })
                    
                } else {
                    self?.show()
                }
            })
        }
        
        
        addAction(image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: config), title: "Report this Contact") { _ in
            self.handleReportContact()
        }
    
        self.addCancelAction()
    }
}

extension ChatMenuAlertController: MFMailComposeViewControllerDelegate {
    
    func handleReportContact() {
        guard let friend = room?.member else { return }
        if MFMailComposeViewController.canSendMail(), let user = GlobalVar.currentUser {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("mMsgr: Report Contact")
            mail.setToRecipients(["mmsgrapp@gmail.com"])
            mail.setMessageBody("<p> mMsgr User ID : \(user.uid), mMsgr Reported User ID : \(friend.uid)</p>", isHTML: true)
            UIApplication.topViewController()?.present(mail, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            if result == .sent {
                self?.AlertPresentable_showAlert(buttonText: "OK", message: "Thank you for Reporting us. We will look into it and get back to you soon !")
            }
        }
    }
    
}
