//
//  AppViewController+DisplayName.swift
//  mMsgr
//
//  Created by Aung Ko Min on 18/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit
import FirebaseAuth

extension AppViewController {
    // Change Name
    func gotoChangeName() {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "Change Name", font: UIFont.preferredFont(forTextStyle: .title2))
        alert.set(message: "Please enter your desired display name.\nNote: English characters only", font: UIFont.preferredFont(forTextStyle: .footnote))
        
        var text: String?
        
        let textFieldConfiguration: TextField.Config = { textField in
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .no
            textField.attributedPlaceholder = NSAttributedString(string: "Enter New Name", attributes: [.font: textField.font!, .foregroundColor: UIColor.secondaryLabel])
            textField.delegate = self
            
            textField.action(closure: { tf in
                text = tf.text
            })
        }
        
        alert.addOneTextField(configuration: textFieldConfiguration)
        
        alert.addAction(image: nil, title: "Continue", color: nil, style: .default, isEnabled: true) { action in
            if let text = text {
                ARSLineProgress.ars_showOnView(self.view)
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = text
                changeRequest?.commitChanges(completion: { (error) in
                    if let error = error {
                        ARSLineProgress.showFail()
                        
                        self.AlertPresentable_showAlertSimple(message: error.localizedDescription)
                    } else {
                        if let user = GlobalVar.currentUser {
                            user.uploadToFirestore(completion: { (done, err) in
                                ARSLineProgress.hideWithCompletionBlock {
                                    self.tableView.reloadData()
                                }
                            })
                        } else {
                            
                            ARSLineProgress.showFail()
                            
                        }
                    }
                })
            } else {
                alert.set(title: "Name shouldn't be empty", font: UIFont.preferredFont(forTextStyle: .headline))
                alert.show()
            }
        }
        
        alert.addCancelAction()
        
        alert.show()
    }
}

extension AppViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard !string.isWhitespace else { return true }
        return string.EXT_isEnglishCharacters
        
    }
}
