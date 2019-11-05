//
//  Login+Email.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import FirebaseAuth


extension LoginController: AlertPresentable {
    
    // Email Login
    
    func goLoginwithEmail() {
        let alert = UIAlertController(style: .actionSheet)
        
        alert.set(title: "Login with Email", font: UIFont.preferredFont(forTextStyle: .callout))
        alert.set(message: "This is only for existing users who have their emails merged with their accounts", font: UIFont.preferredFont(forTextStyle: .footnote))
        
        var email: String = ""
        var password: String = ""
        
        let signInAction = UIAlertAction(title: "Sign In", style: .default) { _ in
            if !email.isEmpty && !password.isEmpty {
                self.authWithEmail(email: email.trimmed, password: password.trimmed)
            } else {
                self.goLoginwithEmail()
            }
        }
        signInAction.isEnabled = false
        
        
        let emailTextField: TextField.Config = { x in

            x.placeholder = "Email Address"
            x.clearButtonMode = .whileEditing
            x.autocapitalizationType = .none
         
            x.keyboardType = .emailAddress
            x.autocorrectionType = .yes
            x.returnKeyType = .continue
            x.textContentType = .username
            x.action { emailTextField in
                email = emailTextField.text ?? ""
            }
        }
        
        let passwordTextField: TextField.Config = { x in
            x.placeholder = "Password"
            x.clearsOnBeginEditing = true
            x.autocapitalizationType = .none

            x.keyboardType = .default
            x.isSecureTextEntry = true
            x.textContentType = .newPassword
            x.returnKeyType = .done
            x.action { passwordTextField in
                password = passwordTextField.text ?? ""
                if !password.isEmpty && !password.isWhitespace {
                    signInAction.isEnabled = !email.isEmpty && !email.isWhitespace
                } else {
                    signInAction.isEnabled = false
                }
            }
        }
        alert.addTwoTextFields(height: 50, hInset: 5, vInset: 5, textFieldOne: emailTextField, textFieldTwo: passwordTextField)
        
        alert.addAction(signInAction)
        
        alert.addCancelAction(title: "Back") { _ in
            self.comfirmCountryCode()
        }

        alert.show()
    }
    
    func authWithEmail(email: String, password: String) {
        ARSLineProgress.show()
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let `self` = self else { return }
            ARSLineProgress.hideWithCompletionBlock {
                if let error = error {
                    self.showFailedEmailLoing(with: error)
                } else {
                    self.checkConfigurations()
                }
            }
        }
    }
    
    private func showFailedEmailLoing(with error: Error?) {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Login Help", font: UIFont.preferredFont(forTextStyle: .callout))
        if let error = error?.localizedDescription {
            alert.set(message: error, font: UIFont.preferredFont(forTextStyle: .subheadline))
            alert.addAction(image: nil, title: "Try Again", color: nil, style: .default, isEnabled: true) { _ in
                self.goLoginwithEmail()
            }
        }
        
        alert.addAction(image: nil, title: "Forget/Reset Password", color: nil, style: .destructive, isEnabled: true) { _ in
            self.forgetPassword()
        }
        
        alert.addAction(image: nil, title: "Login with Phone Number", color: nil, style: .default, isEnabled: true) { _ in
            self.checkConfigurations()
        }

        alert.show()
    }
    
    private func forgetPassword() {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Recover Password", font: UIFont.preferredFont(forTextStyle: .callout))
        alert.set(message: "Pls enter your registered email address", font: UIFont.preferredFont(forTextStyle: .subheadline))
    
        var email = ""
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { _ in
            if !email.isEmpty {
                Auth.auth().sendPasswordReset(withEmail: email.trimmed) { error in
                    if let error = error {
                        self.AlertPresentable_showAlert(buttonText: "OK", title: "Error", message: error.localizedDescription, cancelButton: false, cancelText: nil, style: .destructive, completion: { done in
                            self.goLoginwithEmail()
                        })
                    } else {
                        self.AlertPresentable_showAlert(buttonText: "OK", title: "Success", message: "We have sent a passowrd resetting email to \(email). Please check your email and follow the instructions. ", cancelButton: false, cancelText: nil, style: .default, completion: { _ in
                            self.goLoginwithEmail()
                        })
                    }
                }
            } else {
                self.AlertPresentable_showAlert(buttonText: "OK", title: "Email must not be empty!", message: nil, cancelButton: false, cancelText: nil, style: .destructive, completion: { _ in
                    self.goLoginwithEmail()
                })
            }
        }
        
        continueAction.isEnabled = false
        
        let emailTextField: TextField.Config = { x in
            x.placeholder = "Registered Email Address"
            x.clearButtonMode = .whileEditing
            x.autocapitalizationType = .none
    
            x.keyboardType = .emailAddress
            x.autocorrectionType = .yes
            x.textContentType = .emailAddress
            x.returnKeyType = .continue
            x.action { emailTextField in
                email = emailTextField.text ?? ""
                continueAction.isEnabled = !email.isEmpty && !email.isWhitespace
            }
        }
        alert.addOneTextField(configuration: emailTextField)
        alert.addAction(continueAction)
        
        alert.addCancelAction(title: "Cancel") { _ in
            self.goLoginwithEmail()
        }
        alert.show()
    }
}
