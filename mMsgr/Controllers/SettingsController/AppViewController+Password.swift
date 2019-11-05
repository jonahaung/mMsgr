//
//  AppViewController+Password.swift
//  mMsgr
//
//  Created by Aung Ko Min on 18/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import Firebase

extension AppViewController {
    
    // Password
    
    func checkIfEmailRegistered() {
        guard let currentUser = GlobalVar.currentUser else { return }
    
        if let email = currentUser.email {
            reauthenticate(with: email)
        } else {
            updateEmail()
        }
        
    }
    
    
    private func reauthenticate(with email: String) {
        guard let currentUser = GlobalVar.currentUser else { return }
        
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Update Password", font: UIFont.preferredFont(forTextStyle: .title2))
        alert.set(message: "Please enter your current password.", font: UIFont.preferredFont(forTextStyle: .footnote))
        
        var text: String?
        
        let textFieldConfiguration: TextField.Config = { textField in
            
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.isSecureTextEntry = true
            textField.textContentType = .password
            textField.attributedPlaceholder = NSAttributedString(string: "Enter Current Password", attributes: [.font: textField.font!, .foregroundColor: UIColor.secondaryLabel])
    
            textField.action(closure: { tf in
                text = tf.text
            })
        }
        
        alert.addOneTextField(configuration: textFieldConfiguration)
        
        alert.addAction(image: nil, title: "Continue", color: nil, style: .default, isEnabled: true) { action in
            if let text = text?.trimmed {
                let credential = EmailAuthProvider.credential(withEmail: email, password: text)
                currentUser.reauthenticate(with: credential, completion: { (result, err) in
                    if let error = err {
                        self.AlertPresentable_showAlert(buttonText: "OK", title: "Authentication Failed", message: error.localizedDescription, cancelButton: false, cancelText: nil, style: .default, completion: { accept in
                            self.reauthenticate(with: email)
                        })
                    } else {
                        if let user = result?.user {
                            self.updatePassword(currentUser: user)
                        }
                    }
                })
            } else {
                alert.set(title: "Password shouldn't be empty", font: UIFont.preferredFont(forTextStyle: .headline))
                alert.show()
            }
        }
        
        alert.addAction(image: nil, title: "Set/Reset Password", color: nil, style: .destructive, isEnabled: true) { action in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.AlertPresentable_showAlertSimple(message: error.localizedDescription)
                } else {
                    self.AlertPresentable_showAlert(buttonText: "OK", message: "Success! Please check your email for password reset link.")
                }
            }
        }
        
        
        alert.addCancelAction()
        
        alert.show()
    }
    
    private func updatePassword(currentUser: User) {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Enter New Password", font: UIFont.preferredFont(forTextStyle: .title2))
        alert.set(message: "Please enter your new password.", font: UIFont.preferredFont(forTextStyle: .footnote))
        
        var text: String?
        
        let textFieldConfiguration: TextField.Config = { textField in
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.isSecureTextEntry = true
            if #available(iOS 12.0, *) {
                textField.textContentType = .newPassword
            } else {
                // Fallback on earlier versions
            }
            textField.attributedPlaceholder = NSAttributedString(string: "New Password", attributes: [.font: textField.font!, .foregroundColor: UIColor.secondaryLabel])
           
            textField.action(closure: { tf in
                text = tf.text
            })
        }
        
        alert.addOneTextField(configuration: textFieldConfiguration)
        
        alert.addAction(image: nil, title: "Continue", color: nil, style: .default, isEnabled: true) { action in
            if let text = text?.trimmed {
                currentUser.updatePassword(to: text, completion: { err in
                    if let err = err {
                        self.AlertPresentable_showAlertSimple(message: err.localizedDescription)
                    } else {
                        self.AlertPresentable_showAlert(buttonText: "OK", message: "Password Updated Successfully!")
                    }
                })
            } else {
                alert.set(title: "Password shouldn't be empty", font: UIFont.preferredFont(forTextStyle: .headline))
                alert.show()
            }
        }
        
        alert.addCancelAction()
        
        alert.show()
    }
    
}

extension AppViewController {
    
    
    private func askeToRegisterWithEmail() {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Add Email", font: UIFont.preferredFont(forTextStyle: .title3))
        alert.set(message: "You do not have your email registered to this account.", font: UIFont.preferredFont(forTextStyle: .callout))
        
        alert.addAction(image: nil, title: "Add Email Address", color: UIColor.myappGreen, style: .default, isEnabled: true) { _ in
            self.updateEmail()
        }
        
        alert.addCancelAction()
        alert.show()
    }
    
    func updateEmail() {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Update Email", font: UIFont.preferredFont(forTextStyle: .title2))
        alert.set(message: "Please enter your valid email address", font: UIFont.preferredFont(forTextStyle: .footnote))
        
        var email: String?
        
        let textFieldConfiguration: TextField.Config = { x in
            x.placeholder = "Email Address"
            x.clearButtonMode = .whileEditing
            x.autocapitalizationType = .none
            x.keyboardType = .emailAddress
            x.autocorrectionType = .yes
            x.returnKeyType = .continue
            x.textContentType = .emailAddress
            x.action { tf in
                email = tf.text
            }

        }
        
        alert.addOneTextField(configuration: textFieldConfiguration)
        
        alert.addAction(image: nil, title: "Update", color: nil, style: .default, isEnabled: true) { action in
            if let email = email?.trimmed {
                ARSLineProgress.ars_showOnView(self.view)
                Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                    ARSLineProgress.hideWithCompletionBlock {
                        if let error = error {
                            self.AlertPresentable_showAlert(buttonText: "ReAuthenticate", title: "Error", message: error.localizedDescription, cancelButton: true, cancelText: "Cancel", style: .destructive, completion: { accept in
                                if accept {
                                    self.gotoLogout()
                                }
                            })
                        } else {
                            Auth.auth().currentUser?.sendEmailVerification { (err) in
                                if let err = err {
                                    self.AlertPresentable_showAlert(buttonText: "Try Again", title: "Error", message: err.localizedDescription, cancelButton: true, cancelText: "Cancel", style: .default, completion: { accept in
                                        if accept {
                                            self.updateEmail()
                                        }
                                    })
                                } else {
                                    self.AlertPresentable_showAlert(buttonText: "OK", title: "Success", message: "Please check your email and verify the account", cancelButton: false, cancelText: nil, style: .destructive, completion: { accept in
                                        self.tableView.reloadData()
                                    })
                                }
                            }
                        }
                    }
                    
                }
            } else {
                alert.set(title: "Email shound't be empty", font: UIFont.preferredFont(forTextStyle: .headline))
                alert.show()
            }
        }
        
        alert.addCancelAction()
        
        alert.show()
        
    }
    
//    private func enterEmailAndPassword() {
//        let alert = UIAlertController(style: .actionSheet)
//
//        alert.set(title: "Login with Email", font: UIFont.preferredFont(forTextStyle: .callout))
//        alert.set(message: "This is only for existing users who have their emails merged with their accounts", font: UIFont.preferredFont(forTextStyle: .footnote))
//
//        var email: String = ""
//        var password: String = ""
//
//        let signInAction = UIAlertAction(title: "Sign In", style: .default) { _ in
//            if !email.isEmpty && !password.isEmpty {
//                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//                let user = Auth.auth().currentUser
//
//                user?.linkAndRetrieveData(with: credential, completion: { (result, error) in
//                    if let error = error {
//                        self.AlertPresentable_showAlert(buttonText: "OK", message: error.localizedDescription)
//                    } else {
//                        if let user = result?.user {
//                            self.AlertPresentable_showAlert(buttonText: "OK", message: "Account Linked")
//                        }
//                    }
//                })
//            } else {
//                self.AlertPresentable_showAlert(buttonText: "OK", title: "Error", message: "Email and Password shouldn't be empty", cancelButton: true, cancelText: "Cancel", style: .default, completion: { done in
//                    if done == true {
//                        self.askeToRegisterWithEmail()
//                    }
//                })
//            }
//        }
//        signInAction.isEnabled = false
//
//
//        let emailTextField: TextField.Config = { x in
//            x.left(image: #imageLiteral(resourceName: "user"), color: UIColor(hex: 0x007AFF))
//            x.leftViewPadding = 16
//            x.leftTextPadding = 12
//            x.becomeFirstResponder()
//            x.textColor = self.theme.generalTitleColor
//            x.placeholder = "Email Address"
//            x.clearButtonMode = .whileEditing
//            x.autocapitalizationType = .none
//            x.keyboardAppearance = self.theme.keyboardAppearance
//            x.keyboardType = .emailAddress
//            x.autocorrectionType = .yes
//            x.returnKeyType = .continue
//            x.textContentType = .emailAddress
//            x.action { emailTextField in
//                email = emailTextField.text ?? ""
//            }
//        }
//
//        let passwordTextField: TextField.Config = { x in
//            x.left(image: #imageLiteral(resourceName: "padlock"), color: UIColor(hex: 0x007AFF))
//            x.leftViewPadding = 16
//            x.leftTextPadding = 12
//            x.borderWidth = 1
//            x.borderColor = self.theme.controlButtonsColor.darker()
//            x.placeholder = "Password"
//            x.clearsOnBeginEditing = true
//            x.autocapitalizationType = .none
//            x.keyboardAppearance = self.theme.keyboardAppearance
//            x.keyboardType = .default
//            x.isSecureTextEntry = true
//            x.textContentType = .password
//            x.returnKeyType = .done
//            x.action { passwordTextField in
//                password = passwordTextField.text ?? ""
//                if !password.isEmpty && !password.isWhitespace {
//                    signInAction.isEnabled = !email.isEmpty && !email.isWhitespace
//                } else {
//                    signInAction.isEnabled = false
//                }
//            }
//        }
//        alert.addTwoTextFields(height: 50, hInset: 5, vInset: 5, textFieldOne: emailTextField, textFieldTwo: passwordTextField)
//
//        alert.addAction(signInAction)
//
//        alert.addCancelAction(title: "Back") { _ in
//            self.askeToRegisterWithEmail()
//        }
//
//        alert.show()
//    }
}
