//
//  MainCoordinator.swift
//  mMessenger
//
//  Created by Aung Ko Min on 13/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import UIKit
final class NavigationController: UINavigationController {
    
    
    let backgroundImageView: UIImageView = {
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return $0
    }(UIImageView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let hasFontChanges = previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory
        if hasFontChanges {
            UITraitCollection.applyCurrentTraitsCollection()
        }
        super.traitCollectionDidChange(previousTraitCollection)
        assetFactory.clearCaches()
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            setBackgroundImage()
            setBarImage()
        }
        
    }
}

extension NavigationController {
    
    private func setup(){
        navigationBar.prefersLargeTitles = true
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        toolbar.clipsToBounds = true
        
        setBackgroundImage()
        setBarImage()
        
        backgroundImageView.frame = view.bounds
        view.insertSubview(backgroundImageView, at: 0)
    }
    
    private func setBackgroundImage() {
        let imageName = traitCollection.userInterfaceStyle == .dark ? "bgDark" : "bgLight"
        backgroundImageView.image = UIImage(named: imageName)
    }
    
    private func setBarImage() {
        let imageName = traitCollection.userInterfaceStyle == .dark ? "barDark" : "barLight"
        navigationBar.setBackgroundImage(UIImage(named: imageName), for: .default)
        toolbar.setBackgroundImage(UIImage(named: imageName), forToolbarPosition: .any, barMetrics: .default)
    }
}

extension UINavigationController {
    public func popViewControler(animated: Bool, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                completion()
            })
            self.popViewController(animated: true)
            CATransaction.commit()
        }
    }
}

extension UICollectionView {
    
    func setBackgroundImage() {
        backgroundView = UIImageView(image: UIImage(named: traitCollection.userInterfaceStyle == .dark ? "bgDark" : "bgLight"))
    }
}
extension UITableView {
    
    func setBackgroundImage() {
        backgroundView = UIImageView(image: UIImage(named: traitCollection.userInterfaceStyle == .dark ? "bgDark" : "bgLight"))
    }
}
