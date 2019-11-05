import UIKit
import AudioToolbox

// MARK: - Initializers
extension UIAlertController {
	
    /// Create new alert view controller.
    ///
    /// - Parameters:
    ///   - style: alert controller's style.
    ///   - title: alert controller's title.
    ///   - message: alert controller's message (default is nil).
    ///   - defaultActionButtonTitle: default action button title (default is "OK")
    ///   - tintColor: alert controller's tint color (default is nil)
    convenience init(style: UIAlertController.Style, source: UIView? = nil, title: String? = nil, message: String? = nil, tintColor: UIColor? = nil) {
        self.init(title: title, message: message, preferredStyle: style)
        
        // TODO: for iPad or other views
        let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
        let root = UIApplication.topViewController()?.view
        
        //self.responds(to: #selector(getter: popoverPresentationController))
        if let source = source {
            Log("----- source")
            popoverPresentationController?.sourceView = source
            popoverPresentationController?.sourceRect = source.bounds
        } else if isPad, let source = root, style == .actionSheet {
            Log("----- is pad")
            popoverPresentationController?.sourceView = source
            popoverPresentationController?.sourceRect = CGRect(x: source.bounds.midX, y: source.bounds.midY, width: 0, height: 0)
            //popoverPresentationController?.permittedArrowDirections = .down
            popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        }
        
        if let color = tintColor {
            self.view.tintColor = color
        }
    }
}


// MARK: - Methods
extension UIAlertController {

    func show(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIApplication.topViewController()?.present(self, animated: true, completion: completion)
            
        }
    }
    
    func addAction(image: UIImage? = nil, title: String, color: UIColor? = nil, style: UIAlertAction.Style = .default, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) {
      
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.isEnabled = isEnabled
        
    
        if let image = image {
            action.setValue(image, forKey: "image")
        }
        
        // button title color
        if let color = color {
            action.setValue(color, forKey: "titleTextColor")
        }
        
        addAction(action)
    }
    

    func set(title: String?, font: UIFont) {
        if title != nil {
            self.title = title
        }
        setTitle(font: font)
    }
    
    func setTitle(font: UIFont) {
        
        guard let title = self.title else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        setValue(attributedTitle, forKey: "attributedTitle")
    }
    
    func set(message: String?, font: UIFont) {
        if message != nil {
            self.message = message
        }
        setMessage(font: font)
    }
    
    func setMessage(font: UIFont) {
        guard let message = self.message else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
        setValue(attributedMessage, forKey: "attributedMessage")
    }
    

    func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        setValue(vc, forKey: "contentViewController")
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
}

