//
//  AppUtilities.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import FirebaseAuth

struct AppUtility {
    
    static var isLoggedIn: Bool {
    
        return Auth.auth().currentUser != nil
    }
    
    static func gotoPrivacyPolicy() {
        guard let url = URL(string: "https://mmsgr-1b7a6.firebaseapp.com") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    static func shareApp() {
        if let url = URL(string: "https://itunes.apple.com/app/mmsgr/id1434410940?mt=8") {
            url.shareWithMenu()
        }
    }
    
    static func gotoDeviceSettings() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        AppDelegate.sharedInstance.orientationLock = orientation
    }
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    static func showLoading(show: Bool) {
        show ? ARSLineProgress.show() : ARSLineProgress.hide()
    }
    
    static func getEulaText() -> [AttributedTextBlock] {
        return [
            .caption1("Last updated: 27-August-2018"),
            .footnote("""
➤   This End User License Agreement is between you and mMsgr App 'mMsgr' and governs use of this app made available through the Apple App Store.
➤   By installing the mMsgr App, you agree to be bound by this Agreement and understand that there is no tolerance for objectionable content.
➤   If you do not agree with the terms and conditions of this Agreement, you are not entitled to use the mMsgr App.

"""),
            .subheadline("""
• Parties
 This Agreement is between you and mMsgr only, and not Apple, Inc. 'Apple'. Notwithstanding the foregoing, you acknowledge that Apple and its subsidiaries and third party beneficiaries of this Agreement and Apple has the right to enforce this Agreement against you. mMsgr, not Apple, is solely responsible for the mMsgr and its content.

• Pravicy
 We are determined to protect and maintain your privacy. We are privileged to be trusted with your personal information and do not wish to jeopardize that trust. However, in order to use some of our services, it’s necessary for you to give us details such as your mobile phone number, device contacts and email address, and we will ask your permission for these details where relevant. We may collect and view information about your shared materials such as text, graphics including your registered email and phone number. We may view or use this information, as long as it is in a form that does not personally identify you, to make sure there is no tolerance for objectionable content or abusive users.
We do NOT upload and store your phone's contacts to our server or any other remote places outside the application.
    We do NOT share your information with third parties, we do NOT share your email addresses or phone number with sponsors or any third parties, and we do NOT run exclusive ‘sponsored’, 'phone calls' or 'sms' on behalf of third parties.

• Limited License
 mMsgr grants you a limited, non-exclusive, non-transferable, revocable license to use the mMsgr App for your personal, non-commercial purpose. You may only use the mMsgr App on Apple devices that you own or control and as permitted by the App Store Terms of Service.

• Age Restrictions
 By using mMsgr App, you represent and wrrant that
    (a) you are 12 years of age or older and you agree to be bound by this Agreement
    (b) if you are under 12 years of age, you have obtained verifiable consent from a parent or legal guardian and
    (c) your use of the mMsgr App does not violate any applicable law or regulation.
 Your access to to the mMsgr may be terminated without warning if we believe, in its sole discretion, that you are under the age of 12 years and have not obtained verifiable consent from a parent or legal guardian. If you are a parent or legal guardian and you provide your consent to your child's use of the mMsgr App, you agree to be bound by this Agreement in respect to your child's use of the mMsgr App.

• Objectionable Content Policy
 Contents may not be submitted to mMsgr, who will moderate all content and ultimately decide whether or not to post a submission to the extend such content includes, is in conjunction with, or alongside any, Objectionable Content. Objectionable Content includes, but is not limited to:
    (i) sexually explicit materials
    (ii) obscene, defamatory, libellous, slanderous, violent and/or unlawful content or profanity
    (iii) content that infringes upon the rights of any third party, including copyright, trademark, privacy, publicity or other personal or proprietary right, or that is deceptive or fraudulent
    (iv) content that promotes the use or sale of illegal or regulated substances, tobacco products, ammunition and/or firearms and gambling, including without limitation, any online casino, sports books, bingo or poker.
 In order to ensure mMsgr provides the best experience possible for everyone, we strongly enforce a no tolerance policy for objectionable content or abusive users. If you see inappropriate contents or abusive users, please use "Block this Contact" or "Report this Contact" features found in each contact's profile page.
        mMsgr team will act on objectionable content reports within 24 hours by removing the content and ejecting the user who provided the offending content.

• Warranty
 mMsgr disclaims all warranties about the mMsgr App to the fullest extent permitted by law. To the extent any warranty exits under law that cannot be disclaimed, mMsgr, not Apple, shall be solely responsible for such warranty.

• Maintenance and Support
  mMsgr does provide minimal maintenance or support for it but not to the extent that any maintenance or support is required by applicable law, mMsgr, not Apple, shall be obligated to furnish any such maintenance or support.

• Product Claims
 mMsgr, not Apple, is responsible for addressing any claims by you relating to the mMsgr App or use of it, including, but not limited to:
    (i) any product liability claim
    (ii) any claim that the mMsgr fails to conform to any applicable legal or regulatory requirement and
    (iii) any claim arising under consumer protection or similar legislation.
 Nothing in this Agreement shall be deemed and admission that you may have such claims.

• Third Party Intellectual Property Claims
 mMsgr shall not be obligated to indemnify or defend you with respect to any third party claim arising out or relating to the mMsgr App. To the extent mMsgr is required to provide indemnification by applicable law, mMsgr, not Apple, shall be solely responsible for the investigation, defense, settlement and discharge of any claim that the mMsgr App or your use of it infringes any third party intellectual property right.

YOU EXPRESSLY ACKNOWLEDGE THAT YOU HAVE READ THIS EULA AND UNDERSTAND THE RIGHTS, OBLIGATIONS, TERMS AND CONDITIONS SET FORTH HEREIN.
BY CLICKING ON THE 'I AGREE & CONTINUE' BUTTON, YOU EXPRESSLY CONSENT TO BE BOUND BY ITS TERMS AND CONDITIONS AND GRANT TO MMSGR THE RIGHTS SET FORTH HEREIN.
"""),
        ]
    }
}
