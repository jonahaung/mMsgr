//
//  AppViewController+Others.swift
//  mMsgr
//
//  Created by Aung Ko Min on 18/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import MessageUI

extension AppViewController {
    
    
    // Reset Words
    func resetWords(at indexPath: IndexPath) {
        
        let isZawGyi = userDefaults.currentBoolObjectState(for: userDefaults.isZawgyiInstalled)
        let text = isZawGyi ? "Unicode" : "ZawGyi"
        
        AlertPresentable_showAlert(buttonText: "Apply \(text) Font", title: "Font of Choice", message: "This will reload and reconfigure the built-in words-list dictionary\n(Words/Autocompletes/Translations)", cancelButton: true, cancelText: "Cancel", style: .destructive) { yes in
            if yes {
                userDefaults.updateObject(for: userDefaults.isZawgyiInstalled, with: !isZawGyi)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    // Conversation Style
    func toggleConversationstyle(at indexPath: IndexPath) {
        var backgrounds = ["Plain", "BG-1", "BG-2", "BG-3", "BG-4", "BG-5"]
        
        let currentBackground = userDefaults.currentStringObjectState(for: userDefaults.backgroundImageName) ?? "Plain"
        
        backgrounds.removeAll(currentBackground)
        
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Conversation Background", font: UIFont.preferredFont(forTextStyle: .callout))
        alert.set(message: "Current: \(currentBackground)", font: UIFont.preferredFont(forTextStyle: .callout))
        
        backgrounds.forEach { bg in
            alert.addAction(image: nil, title: bg, color: UIColor.randomColor(), style: .default, isEnabled: true) { _ in
                userDefaults.updateObject(for: userDefaults.backgroundImageName, with: bg)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                SoundManager.playSound(tone: .Typing)
            }
        }
        
        alert.addCancelAction()
        alert.show()
    }
    // Logout
    func gotoLogout() {
        
        AlertPresentable_showAlert(buttonText: "Continue Logout", title: "Warning", message: "All the messages and media items will be deleted. Continue to logout?", cancelButton: true, style: .destructive) { ok in
            guard ok == true else { return }
            DispatchQueue.main.safeAsync {
                AppDelegate.sharedInstance.logout(user: GlobalVar.currentUser)
            }
        }
    }
    
    
    // Guide
    func gotoGuide() {
        let vc = GuideController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // About Developer
    func aboutDeveloper () {

        let vc = AboutDeveloperController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Contact Us
    func gotoContactUs() {
        if MFMailComposeViewController.canSendMail(), let user = GlobalVar.currentUser {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("mMsgr: Feedback")
            mail.setToRecipients(["mmsgrapp@gmail.com"])
            mail.setMessageBody("<p> mMsgr User ID : \(user.uid)</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    // Privacy
    func gotoPrivacy() {
        AppUtility.gotoPrivacyPolicy()
    }
    
    // EULA
    func gotoEULA() {
        
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "App End User License Agreement", font: UIFont.preferredFont(forTextStyle: .title3))
        
        alert.addTextViewer(text: .attributedTextBlock(AppUtility.getEulaText()))
        
        alert.addCancelAction()
        alert.show()
    }
    
    // Share App
    func gotoShareApp() {
        AppUtility.shareApp()
    }
    
    // Open App Settings
    func gotoAppSettings() {
        AppUtility.gotoDeviceSettings()
    }
}


// Email
extension AppViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            if result == .sent {
                self?.AlertPresentable_showAlert(buttonText: "OK", message: "Thank you for contacting us. Have a nice day !")
            }
        }
        
    }
    
}
