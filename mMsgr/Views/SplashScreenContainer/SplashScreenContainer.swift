//
//  SplashScreenContainer.swift
//  Pigeon-project
//
//  Created by Roman Mizin on 4/16/18.
//  Copyright © 2018 Roman Mizin. All rights reserved.
//

import UIKit
import LocalAuthentication
enum BiometricType: Int {
    case none = 0
    case touch = 1
    case face = 2
}

class SplashScreenContainer: UIView {
    
    
    let localAuthenticationContext = LAContext()
    private let imageView = UIImageView()
    private let lockButton = RoundedButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        isUserInteractionEnabled = true
        doesDeviceHaveBiometrics()
    
        imageView.size = CGSize(150)
        imageView.image = UIImage(systemName: "lock.shield.fill")?.applyingSymbolConfiguration(.init(pointSize: 120, weight: .regular, scale: .large))
        
        lockButton.size = CGSize(44)
        lockButton.image = UIImage(systemName: "lock")?.applyingSymbolConfiguration(.init(pointSize: 40, weight: .thin, scale: .medium))
        lockButton.highlightedImage = UIImage(systemName: "lock.open")?.applyingSymbolConfiguration(.init(pointSize: 40, weight: .thin, scale: .medium))
        lockButton.tintColor = UIColor.myAppYellow
        
        addSubview(imageView)
        addSubview(lockButton)
        
        
        lockButton.action { [weak self] x in
            SoundManager.playSound(tone: .Tock)
            vibrate(vibration: .error)
            self?.authenticationWithTouchID()
            
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func doesDeviceHaveBiometrics() {
        let type = SplashScreenContainer.biometricType()
        
        userDefaults.updateObject(for: userDefaults.biometricType, with: type.rawValue)
    }
    
    static func biometricType() -> BiometricType {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(authContext.biometryType) {
            case .none:
                return .none
            case .touchID:
                return .touch
            case .faceID:
                return .face
            @unknown default:
                fatalError()
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = imageView.size.bma_rect(inContainer: bounds, xAlignament: .center, yAlignment: .center)
        lockButton.frame = lockButton.size.bma_rect(inContainer: bounds, xAlignament: .right, yAlignment: .bottom, dx: -20, dy: -20)
    }

}


extension SplashScreenContainer {
    
    func showSecuredData() {
        DispatchQueue.main.async {
            vibrate(vibration: .success)
            self.removeFromSuperview()
            
        }
    }
    
    
    @objc func authenticationWithTouchID() {
        
        var authError: NSError?
        let reason = "Action of verifying the identity of a user is needed to get access to data"
        
        
        
        guard localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            guard let error = authError else { return }
            self.showPasscodeController(error: error, reason: reason)
            return
        }
    
        localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
            guard !success else { self.showSecuredData(); return }
            guard let error = evaluateError else { return }
            self.showPasscodeController(error: error as NSError, reason: reason)
        }
    }
    
    func showPasscodeController(error: NSError?, reason: String) {
        var error = error
        
        guard localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            self.showSecuredData()
            return
        }
        
        localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason, reply: { (success, error) in
            guard !success else { self.showSecuredData(); return }
            print("Authentication was error")
            
        })
    }
}
