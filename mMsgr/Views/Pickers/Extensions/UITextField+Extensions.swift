import UIKit

// MARK: - Properties

extension UITextField {
    
    public typealias TextFieldConfig = (UITextField) -> Swift.Void
    
    public func config(textField configurate: TextFieldConfig?) {
        configurate?(self)
    }
    
    func left(image: UIImage?, color: UIColor = .black) {
        if let image = image {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(image: image)
            imageView.tintColor = UIColor.randomColor()
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
    }
    
    func right(image: UIImage?, color: UIColor = .black) {
        if let image = image {
            rightViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(image: image)
            imageView.tintColor = UIColor.randomColor()
            rightView = imageView
        } else {
            rightViewMode = UITextField.ViewMode.never
            rightView = nil
        }
    }
}

// MARK: - Methods

public extension UITextField {
    
    /// Set placeholder text color.
    ///
    /// - Parameter color: placeholder text color.
    func setPlaceHolderTextColor(_ color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
    }
    
    /// Set placeholder text and its color
    func placeholder(text value: String, color: UIColor = .red) {
        self.attributedPlaceholder = NSAttributedString(string: value, attributes: [ NSAttributedString.Key.foregroundColor : color])
    }
}
