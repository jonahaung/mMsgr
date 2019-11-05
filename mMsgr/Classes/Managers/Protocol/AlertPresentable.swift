//
//  ErrorAlertPresentable.swift
//  mMessenger
//
//  Created by Aung Ko Min on 14/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//
import UIKit

internal protocol AlertPresentable {}

internal extension AlertPresentable {

    func AlertPresentable_showAlertSimple(title: String? = nil, message: String) {
        vibrate(vibration: .error)
        let alert = UIAlertController(style: .actionSheet)
        if let title = title {
            alert.set(title: title, font: UIFont.preferredFont(forTextStyle: .title2))
        }
        alert.set(message: message, font: UIFont.preferredFont(forTextStyle: .callout))
        
        alert.addAction(title: "OK")
        alert.show()
    }

    func AlertPresentable_showAlert(buttonText: String, title: String? = nil, message: String?, cancelButton: Bool = false, cancelText: String? = "Cancel", style: UIAlertAction.Style = .default, completion: ((Bool) -> Void)? = nil) {
    

        let alert = UIAlertController(style: .actionSheet)
        if let title = title {
            alert.set(title: title, font: UIFont.preferredFont(forTextStyle: .title2))
        }
        if let message = message {
            alert.set(message: message, font: UIFont.preferredFont(forTextStyle: .callout))
        }
        let actionOK = UIAlertAction(title: buttonText, style: style) {
            _ in
            completion?(true)
        }
        alert.addAction(actionOK)

        if cancelButton {
            alert.addCancelAction { _ in
                completion?(false)
            }
        }

        alert.show()
    }
}
