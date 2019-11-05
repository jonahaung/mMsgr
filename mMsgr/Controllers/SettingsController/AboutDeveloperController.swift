//
//  AboutDeveloperController.swift
//  mMsgr
//
//  Created by jonahaung on 24/8/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import UIKit
import MessageUI

class AboutDeveloperController: UIViewController, AlertPresentable, MainCoordinatorDelegatee {
    
    let scrollView: UIScrollView = {
        let x = UIScrollView()
        x.alwaysBounceVertical = true
        x.bounces = true
        return x
    }()

    override func loadView() {
        view = scrollView
    }
    
    lazy var stackView: UIStackView = {
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "programmar"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        
        let nameLabel = UILabel()
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        nameLabel.textAlignment = .center
        nameLabel.text = "Aung Ko Min"
        
        let detailLabel = UILabel()
        detailLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        detailLabel.textAlignment = .center
        detailLabel.textColor = UIColor.secondaryLabel
        detailLabel.numberOfLines = 0
        detailLabel.text = "The beauty you see in me is a reflection of you"
        
        let x = UIStackView(arrangedSubviews: [imageView, nameLabel, detailLabel])
        x.distribution = .fill
        x.spacing = 15
        x.alignment = .fill
        x.axis = .vertical
        x.translatesAutoresizingMaskIntoConstraints = false
        return x
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

extension AboutDeveloperController {
    
    private func makeButton(title: String, color: UIColor) -> UIButton {
        let x = UIButton(type: .system)
        x.setTitle(title, for: .normal)
        x.clipsToBounds = true
        x.layer.borderColor = color.cgColor
        x.layer.cornerRadius = 8
        x.layer.borderWidth = 1
        x.setTitleColor(color, for: .normal)
        return x
    }
    
    private func setup() {
        
        view.backgroundColor = UIColor.systemBackground
        
        setupNavigateionItems()
        
        let linkedIn = makeButton(title: "LinkedIn", color: UIColor.myappGreen)
        linkedIn.addTarget(nil, action: #selector(didTapLinkedIn), for: .touchUpInside)
        
        let emailButton = makeButton(title: "Email", color: UIColor.myAppYellow)
        emailButton.addTarget(nil, action: #selector(didTapEmail), for: .touchUpInside)
        
        let facebookButton = makeButton(title: "Facebook", color: UIColor.systemBlue)
        facebookButton.addTarget(nil, action: #selector(didTapFacebook), for: .touchUpInside)
        
        let twitterButton = makeButton(title: "Twitter", color: UIColor.myAppRed)
        twitterButton.addTarget(nil, action: #selector(didTapTwitter), for: .touchUpInside)
        

        stackView.addArrangedSubview(linkedIn)
        stackView.addArrangedSubview(emailButton)
        stackView.addArrangedSubview(facebookButton)
        stackView.addArrangedSubview(twitterButton)
        
        view.addSubview(stackView)
        stackView.addConstraints(view.topAnchor, left: nil, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 50, rightConstant: 0, widthConstant: 280, heightConstant: 0)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
    }
    
    private func setupNavigateionItems() {
        navigationItem.title = "About Developer"
    }
    
    @objc private func didTapEmail() {
       
        if MFMailComposeViewController.canSendMail(), let user = GlobalVar.currentUser {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["jonahaung@gmail.com"])
            mail.setMessageBody("<p> mMsgr User ID : \(user.uid)</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    
    
    @objc private func didTapFacebook() {
        
        if let url = URL(string: "fb://profile/jonah.aung.12") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],completionHandler: { (success) in
                    print("Open fb://profile/jonah.aung.12: \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open fb://profile/538352816: \(success)")
            }
        }
    }
    
    @objc private func didTapTwitter() {
       
        let twUrl = URL(string: "twitter://user?screen_name=JonahAungKoMin")!
        let twUrlWeb = URL(string: "https://www.twitter.com/JonahAungKoMin")!
        if UIApplication.shared.canOpenURL(twUrl){
            UIApplication.shared.open(twUrl, options: [:],completionHandler: nil)
        }else{
            UIApplication.shared.open(twUrlWeb, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func didTapLinkedIn() {
        
        if let url = URL(string: "https://www.linkedin.com/in/aung-ko-min-jonah-382391176") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],completionHandler: { (success) in
                    print(success)
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print(success)
            }
        }
    }
}

extension AboutDeveloperController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        if result == .sent {
            AlertPresentable_showAlert(buttonText: "OK", message: "Thank you for contacting me. Have a nice day !")
        }
    }
    
}
