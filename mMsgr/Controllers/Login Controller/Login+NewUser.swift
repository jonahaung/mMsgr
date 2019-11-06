//
//  Login+NewUser.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import FirebaseAuth

extension LoginController {
    
    func gotoChangeName(user: User) {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Register", font: UIFont.preferredFont(forTextStyle: .title2))
        alert.set(message: "Please enter your desired display name.\n(English Characters Only)", font: UIFont.preferredFont(forTextStyle: .footnote))
        
        var text: String?
        
        let textFieldConfiguration: TextField.Config = { textField in
            textField.backgroundColor = UIColor.tertiarySystemFill
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .no
            textField.placeholder = "Display Name"
            textField.delegate = self
            textField.textContentType = .name
            
            textField.action(closure: { tf in
                text = tf.text
            })
        }
        
        alert.addOneTextField(configuration: textFieldConfiguration)
        
        alert.addAction(image: nil, title: "Continue", color:nil, style: .default, isEnabled: true) { action in
            if let text = text {
            
                ARSLineProgress.ars_showOnView(self.view)
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = text
                changeRequest?.commitChanges(completion: { [weak self] (error) in
                    guard let `self` = self else { return }
                    ARSLineProgress.hideWithCompletionBlock {[weak self] in
                         guard let `self` = self else { return }
                        if let error = error {
                            self.AlertPresentable_showAlert(buttonText: "OK", title: "Error", message: error.localizedDescription, cancelButton: false, cancelText: nil, style: .destructive, completion: { [weak self] done in
                            guard let `self` = self else { return }
                                self.checkConfigurations()
                            })
                        } else {
                            self.checkConfigurations()
                        }
                    }
                    
                })
            } else {
                alert.set(title: "Name shouldn't be empty", font: UIFont.preferredFont(forTextStyle: .headline))
                alert.show()
            }
        }
        
        alert.addCancelAction(title: "Cancel") { [weak self] _ in
            self?.checkConfigurations()
        }
        
        alert.show()
    }
    
}


extension LoginController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard !string.isWhitespace else { return true }
        return string.EXT_isEnglishCharacters
        
    }
}
extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, MediaPicker {
    
    func requestUpdatePhoto(user: User) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.set(title: "Upload Profile Photo", font: UIFont.preferredFont(forTextStyle: .title3))
        
        alert.addAction(image: nil, title: "Camera", color: nil, style: .default, isEnabled: true) { _ in
            self.MediaPicker_OpenCamera(.PhotoCamera)
        }
        alert.addAction(image: nil, title: "Photo Library", color: nil, style: .default, isEnabled: true) { _ in
            self.MediaPicker_OpenCamera(.PhotoLibrary)
        }

        alert.addCancelAction { _ in
            self.checkConfigurations()
        }
        
        alert.show()
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
        self.checkConfigurations()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }
            if let image = info[.editedImage] as? UIImage, let resizedImage = image.EXT_circleMasked?.resizeScaleImage(preferredWidth: 150) {
                self.changePhoto(image: resizedImage)
            }else if let image = info[.originalImage] as? UIImage, let resizedImage = image.EXT_circleMasked?.resizeScaleImage(preferredWidth: 150) {
                self.changePhoto(image: resizedImage)
            }
        }
    }
    
    
    private func changePhoto(image: UIImage) {
        
        
        if let user = Auth.auth().currentUser, let data = image.pngData() {
            ARSLineProgress.show()
            let thumbURL = user.photoURL_local
            
            let storage = user.avatar_storage_reference
            try? data.write(to: thumbURL, options: .atomic)
            
            storage.putData(data as Data, metadata: nil) { [weak self] (meta, err) in
                guard let `self` = self else {
                    ARSLineProgress.hide()
                    return }
                
                if let error = err {
                    ARSLineProgress.hide()
                    self.AlertPresentable_showAlert(buttonText: "OK", title: "Error", message: error.localizedDescription, cancelButton: false, cancelText: nil, style: .destructive, completion: { done in
                        self.checkConfigurations()
                    })
                } else {
                    storage.downloadURL(completion: { [weak self] (url, err) in
                        guard let `self` = self else {
                            ARSLineProgress.hide()
                            return }
                        if let error = err {
                            ARSLineProgress.hide()
                            self.AlertPresentable_showAlert(buttonText: "OK", title: "Error", message: error.localizedDescription, cancelButton: false, cancelText: nil, style: .destructive, completion: { done in
                               self.checkConfigurations()
                            })
                            
                        } else {
                            let changeRequest = user.createProfileChangeRequest()
                            changeRequest.photoURL = url
                            changeRequest.commitChanges { [weak self] (error) in
                                guard let `self` = self else {
                                    ARSLineProgress.hide()
                                    return }
                                if let error = error {
                                    ARSLineProgress.hide()
                                    self.AlertPresentable_showAlert(buttonText: "OK", title: "Error", message: error.localizedDescription, cancelButton: false, cancelText: nil, style: .destructive, completion: { done in
                                        self.checkConfigurations()
                                    })
                                } else {
                                    ARSLineProgress.hideWithCompletionBlock {
                                        self.checkConfigurations()
                                    }
                                }
                            }
                        }
                    })
                }
            }
        }
    }
}
