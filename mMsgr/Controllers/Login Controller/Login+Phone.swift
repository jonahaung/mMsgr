//
//  Login+Phone.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import FirebaseAuth

extension LoginController {
    
    // Phone Login
    
    // Comfirm Country Code
    func comfirmCountryCode() {
        
        let locale = Locale.current
        let regionCode = locale.regionCode ?? ""
        let phone = phoneNumberKit.countryCode(for: regionCode) ?? 0
        let country = locale.localizedString(forRegionCode: regionCode) ?? ""
        let alert = UIAlertController(style: .actionSheet)
        
        alert.set(title: "mMsgr Login", font: UIFont.preferredFont(forTextStyle: .title1))
        alert.set(message: "Please confirm the \"Country Code\" of your mobile phone number", font: UIFont.preferredFont(forTextStyle: .callout))
        
        let ph = "+\(phone)"
        let flag = Locale.flagImage(for: regionCode)
        alert.addAction(image: flag, title: "\(country)  \(ph)") { [weak self] _ in
            guard let `self` = self else { return }
            self.enterPhoneNumber(with: ph)
        }
        
        alert.addAction(title: "Select Different Country") {  [weak self] _ in
            guard let `self` = self else { return }
            self.pickCountry()
        }
        
        alert.addAction(title: "Login with Email") {  [weak self] _ in
            guard let `self` = self else { return }
            self.goLoginwithEmail()
        }
        alert.show()
        
    }
    
    
    // Pick Country
    private func pickCountry() {
        let alert = UIAlertController(style: .actionSheet)
        alert.addLocalePicker(type: .phoneCode) { info in
            if let phone = info?.phoneCode {
                self.enterPhoneNumber(with: phone)
            }
        }
        alert.addCancelAction() { _ in
            self.checkConfigurations()
        }
        alert.show()
    }
    // +959791000766
    // Enter Phone Number
    private func enterPhoneNumber(with countryCode: String) {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Phone Login", font: UIFont.preferredFont(forTextStyle: .title1))
        alert.set(message: "Enter your valid mobile phone number", font: UIFont.preferredFont(forTextStyle: .subheadline))
        
        var phoneNumber = ""
        if let existing = userDefaults.currentStringObjectState(for: userDefaults.phoneNumber), !existing.isWhitespace {
            phoneNumber = existing
        }
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { _ in
            ARSLineProgress.show()
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    ARSLineProgress.hideWithCompletionBlock {
                        self.AlertPresentable_showAlert(buttonText: "OK", title: "Error", message: error.localizedDescription, cancelButton: false, cancelText: nil, style: .destructive, completion: { done in
                            self.checkConfigurations()
                        })
                    }
                    
                    return
                }
                
                if let vid = verificationID {
                    userDefaults.updateObject(for: userDefaults.phoneNumber, with: phoneNumber)
                    userDefaults.updateObject(for: userDefaults.authVerificationID, with: vid)
                    ARSLineProgress.hideWithCompletionBlock {
                        self.enterCode(vid: vid)
                    }
                    
                }
            }
        }
        
        alert.addOneTextField {[unowned self, unowned continueAction] x in
            x.placeholder = countryCode
            x.keyboardType = .phonePad
            x.textContentType = .telephoneNumber
            if !phoneNumber.isWhitespace {
                x.text = phoneNumber
            }
            x.action {[unowned self, unowned continueAction] textField in
                phoneNumber = textField.text ?? ""
                if !phoneNumber.isWhitespace {
                    if let validNumber = try? self.phoneNumberKit.parse(phoneNumber) {
                        let isValid = validNumber.type.rawValue == "mobile"
                        phoneNumber = ("+\(validNumber.countryCode)\(validNumber.nationalNumber)").trimmed
                        continueAction.isEnabled = isValid
                    } else {
                        phoneNumber = ""
                        continueAction.isEnabled = false
                    }
                } else {
                    continueAction.isEnabled = false
                }
            }
        }
        alert.addAction(continueAction)
        alert.addCancelAction { _ in
            self.checkConfigurations()
        }
        alert.show()
    }
    
    
    private func enterCode(vid: String) {
        guard let vid = userDefaults.currentStringObjectState(for: userDefaults.authVerificationID), let phoneNumber = userDefaults.currentStringObjectState(for: userDefaults.phoneNumber) else {
            checkConfigurations()
            return
        }
        
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Enter One Time Code", font: UIFont.preferredFont(forTextStyle: .title3))
        alert.set(message: "Please enter the SMS code sent to \(phoneNumber)", font: UIFont.preferredFont(forTextStyle: .callout))
        
        var code = ""
        
        let loginAction = UIAlertAction(title: "Login", style: .default) {  [unowned self] _ in
           
            let credential = PhoneAuthProvider.provider().credential (withVerificationID: vid, verificationCode: code.trimmed)
            ARSLineProgress.show()
            Auth.auth().signIn(with: credential, completion: {[unowned self] (result, error) in
                if let error = error {
                    ARSLineProgress.hideWithCompletionBlock {
                        self.AlertPresentable_showAlert(buttonText: "OK", title: "Error", message: error.localizedDescription, cancelButton: false, cancelText: nil, style: .destructive, completion: { _ in
                            self.checkConfigurations()
                        })
                    }
                    return
                }
                ARSLineProgress.hideWithCompletionBlock {
                    if result?.user != nil {
                        self.checkConfigurations()
                    } else {
                        self.AlertPresentable_showAlert(buttonText: "OK", title: "Error", message: "Login Failed", cancelButton: false, cancelText: nil, style: .destructive, completion: { _ in
                            self.checkConfigurations()
                        })
                    }
                }
            })
        }
        
        loginAction.isEnabled = false
        alert.addOneTextField { x in
            x.leftViewPadding = 12
            x.backgroundColor = UIColor.tertiarySystemFill
            x.placeholder = "Code"
            x.keyboardType = .numberPad
            x.textContentType = .oneTimeCode
            x.action { textField in
                code = textField.text ?? ""
                loginAction.isEnabled = !code.isEmpty && !code.isWhitespace && code.count > 2
            }
        }
        alert.addAction(loginAction)
        
        let retry = UIAlertAction(title: "Retry", style: .destructive) { _ in
            self.checkConfigurations()
        }
        alert.addAction(retry)
        alert.show()
    }
    
    
}


extension Locale {
    static func flagImage(for regionCode: String) -> UIImage? {
        return UIImage(named: "Countries.bundle/Images/\(regionCode.uppercased())", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }
}
