//
//  UIViewControllerExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 14/11/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

enum CameraType {
    case PhotoLibrary, PhotoCamera, VideoLibrary, VideoCamera
}

protocol MediaPicker: AnyObject { }

extension MediaPicker where Self: UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func MediaPicker_OpenCamera(_ type: CameraType) {
        switch type {
        case .PhotoLibrary:
            openMediaLibrary(video: false)
        case .PhotoCamera:
            openCamera(video: false)
        case .VideoLibrary:
            openMediaLibrary(video: true)
        case .VideoCamera:
            openCamera(video: true)
        }
    }
    
    private func openCamera(video: Bool = false) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return assertionFailure("Device camera is not availbale")
        }
        
        let imagePicker  = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = .off
        imagePicker.mediaTypes = video ? [kUTTypeMovie as String] : [kUTTypeImage as String]
        imagePicker.cameraCaptureMode = video ? .video : .photo
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func openMediaLibrary(video: Bool = false) {
        if video {
            let type = kUTTypeMovie as String
            if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
                if let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                    if (availableMediaTypes.contains(type)) {
                        
                        let imagePicker = UIImagePickerController()
                        imagePicker.sourceType = .photoLibrary
                        imagePicker.mediaTypes = [type]
                        imagePicker.videoMaximumDuration = TimeInterval(GlobalVar.kVIDEO_MAX_DURATION)
                        
                        imagePicker.allowsEditing = true
                        imagePicker.delegate = self
                        present(imagePicker, animated: true)
                    }
                }
            }
            
            if (UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)) {
                if let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                    if (availableMediaTypes.contains(type)) {
                        
                        let imagePicker = UIImagePickerController()
                        imagePicker.sourceType = .savedPhotosAlbum
                        imagePicker.mediaTypes = [type]
                        imagePicker.videoMaximumDuration = TimeInterval(GlobalVar.kVIDEO_MAX_DURATION)
                        
                        
                        imagePicker.allowsEditing = true
                        imagePicker.delegate = self
                        self.present(imagePicker, animated: true)
                        
                    }
                }
            }
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .savedPhotosAlbum
            
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                picker.mediaTypes = mediaTypes
            }
            present(picker, animated: true, completion: nil)
        }
    }
}
