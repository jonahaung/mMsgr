//
//  LandingController.swift
//  mMsgr
//
//  Created by jonahaung on 29/9/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import PhoneNumberKit
import Firebase
final class LoginController: UIViewController, MainCoordinatorDelegatee {
  
    lazy var phoneNumberKit = PhoneNumberKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setup()
    }
    
    override func loadView() {
        view = UIImageView(image: #imageLiteral(resourceName: "background"))
    }
    var isFirstLoading = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoading {
            isFirstLoading = false
            checkConfigurations()
        }
    }
    
    func checkConfigurations() {
        
        guard hasDoneEULA else {
            goDoneEULA()
            return
        }
        
        guard let user = GlobalVar.currentUser else {
            comfirmCountryCode()
            return
        }
        
        guard user.displayName != nil else {
            gotoChangeName(user: user)
            return
        }
        
        guard user.photoURL != nil else {
            requestUpdatePhoto(user: user)
            return
        }
        user.uploadToFirestore { (done, err) in
            DispatchQueue.main.async {
                ARSLineProgress.showSuccess()
                AppDelegate.sharedInstance.login(user: user)
            }
        }
    }
    
    
    // EULA
    private var hasDoneEULA: Bool {
        return userDefaults.currentBoolObjectState(for: userDefaults.hasAgreeTerms)
    }
    private func goDoneEULA() {
        let alert = UIAlertController(style: .actionSheet)
        alert.set(title: "App End User License Agreement", font: UIFont.preferredFont(forTextStyle: .title3))
        
        alert.addTextViewer(text: .attributedTextBlock(AppUtility.getEulaText()))
        
        alert.addAction(image: nil, title: "I Agree & Continue", color: UIColor.systemBlue, style: .default, isEnabled: true) { agree in
            userDefaults.updateObject(for: userDefaults.hasAgreeTerms, with: true)
            self.checkConfigurations()
        }
        alert.addAction(image: nil, title: "I Do Not Agree", color: UIColor.myAppRed, style: .default, isEnabled: true) { _ in
            self.goDoneEULA()
        }
        alert.show()
    }
    
    let label = UILabel()
}


extension LoginController {
    
    private func setup() {
        label.textColor = UIColor.n1DarkestGreyColor
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.text = "mMsgr"
        label.sizeToFit()
        view.addSubview(label)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        label.frame = label.bounds.size.bma_rect(inContainer: view.bounds.inset(by: view.safeAreaInsets), xAlignament: .right, yAlignment: .top, dx: -20, dy: 50)
    }
}
