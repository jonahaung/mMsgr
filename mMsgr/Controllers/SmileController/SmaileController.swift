//
//  SmaileController.swift
//  mMsgr
//
//  Created by Aung Ko Min on 24/11/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
protocol SmileControllerDelegate: class {
    func smileController_didFinishDetectingSmile(hasSmile: Bool)
    func smileController_didCancel()
}

class SmaileController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MainCoordinatorDelegatee {
    
    weak var delegate: SmileControllerDelegate?
    var isFirstTime = true
    private var countDown = 1
    private var timer:Timer?
    
   
    private let countDownLabel: UILabel = {
        let x = UILabel()
        x.textAlignment = .center
        x.font = UIFont.preferredFont(forTextStyle: .title1)
        x.numberOfLines = 0
        x.text = "Hello \(GlobalVar.currentUser?.displayName?.firstWord ?? "")"
        return x
    }()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        
        countDownLabel.preferredMaxLayoutWidth = view.frame.width - 50
        view.addSubview(countDownLabel)
        countDownLabel.centerInSuperview()
    }
    
    fileprivate func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(updateCountDown), userInfo: nil, repeats: true)
        }else {
            dimissController(hasSmile: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstTime {
            isFirstTime = false
            takePhoto()
        }
    }
    
    deinit {
        print("#### DEINIT: SmileController")
    }
    

    
    // Label
    
    @objc private func updateCountDown() {
        if(countDown > 0) {
            countDownLabel.text = "Pls take your face photo.."
            countDown = countDown - 1
        } else {
            removeCountDownLable()
        }
    }

    private func removeCountDownLable() {
        countDown = 1
        timer?.invalidate()
        timer = nil
        _ = PresentSmileCamera(target: self)
    }
    
    // Image Picker
    
    
    
    fileprivate func dimissController(hasSmile: Bool) {
        dismiss(animated: true) {   [weak self] in
            self?.delegate?.smileController_didFinishDetectingSmile(hasSmile: hasSmile)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.delegate?.smileController_didCancel()
        }
    }
    
    private func detect(image: UIImage) {
        let options: [String: Any] =
            [CIDetectorSmile: true, CIDetectorImageOrientation: NSNumber(value: 5) as NSNumber]
        let personciImage = CIImage(cgImage: image.cgImage!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage, options: options)
        if let face = faces?.first as? CIFaceFeature {
            dimissController(hasSmile: face.hasSmile)
        } else {
            countDownLabel.text = "Face not found !"
            takePhoto()
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            self.detect(image: image)
        } else {
            self.takePhoto()
        }
    }
}
