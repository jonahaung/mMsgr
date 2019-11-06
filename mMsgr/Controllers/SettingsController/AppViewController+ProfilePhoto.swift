//
//  AppViewController+ProfilePhoto.swift
//  mMsgr
//
//  Created by Aung Ko Min on 17/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit


extension AppViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, MediaPicker {
    
    func requestUpdatePhoto() {
        
        AlertPresentable_showAlert(buttonText: "Update Profile Photo?", message: nil, cancelButton: true, style: .default) { ok in
            guard ok == true else { return }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let photoCamera = UIAlertAction(title: "Camera", style: .default) { [unowned self] _ in
                self.MediaPicker_OpenCamera(.PhotoCamera)
            }
            let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { [unowned self] _ in
                self.MediaPicker_OpenCamera(.PhotoLibrary)
            }
           
            alert.addAction(photoCamera)
            alert.addAction(photoLibrary)
            alert.addCancelAction()
            
            alert.show()
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        tableHeaderView.refreshImage(refresh: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let `self` = self else { return }
            if let image = info[.editedImage] as? UIImage, let resizedImage = image.EXT_circleMasked?.resizeScaleImage(preferredWidth: 300) {
                self.changePhoto(image: resizedImage)
            }else if let image = info[.originalImage] as? UIImage, let resizedImage = image.EXT_circleMasked?.resizeScaleImage(preferredWidth: 300) {
                self.changePhoto(image: resizedImage)
            }
        }
    }
    
    
    func changePhoto(image: UIImage) {
        
        
        if let user = GlobalVar.currentUser, let data = image.pngData() {
            let thumbURL = user.photoURL_local
            
            ARSLineProgress.show()
            
            let storage = user.avatar_storage_reference
            try? data.write(to: thumbURL, options: .atomic)
            
            storage.putData(data as Data, metadata: nil) { [weak self] (meta, err) in
                guard let sself = self else {
                    ARSLineProgress.hide()
                    return }
                if let err = err {
                    ARSLineProgress.hide()
                    sself.AlertPresentable_showAlertSimple(message: err.localizedDescription)
                    return
                }
                
                
                storage.downloadURL(completion: { [weak self] (url, err) in
                    guard let sself = self else {
                        ARSLineProgress.hide()
                        return }
                    
                    if let error = err {
                        ARSLineProgress.hide()
                        sself.AlertPresentable_showAlertSimple(message: error.localizedDescription)
                        return
                    }
                    
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.photoURL = url
                    changeRequest.commitChanges { [weak self] (error) in
                        guard let `self` = self else {
                            ARSLineProgress.hide()
                            return }
                        if let error = error {
                            ARSLineProgress.hide()
                            self.AlertPresentable_showAlertSimple(message: error.localizedDescription)
                            return
                        }
                        
                        user.uploadToFirestore(completion: { (done, err) in
                            ARSLineProgress.hide()
                            guard err == nil else {
                                return
                            }
                            if done == true {
                                DispatchQueue.main.async {
                                    self.avatarImageView.currentImage = image
                                }
                            }
                        })
                    }
                    
                })
            }
        }
    }
}
