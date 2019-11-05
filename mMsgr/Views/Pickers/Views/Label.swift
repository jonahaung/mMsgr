import UIKit


class Label: UILabel {
    
    typealias Action = (Label) -> Swift.Void
    
    fileprivate var actionOnTouch: Action?
    
    var insets: UIEdgeInsets = .zero
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    func action(_ closure: @escaping Action) {
        
        if actionOnTouch == nil {
            let gesture = UITapGestureRecognizer(
                target: self,
                action: #selector(Label.actionOnTouchUpInside))
            gesture.numberOfTapsRequired = 1
            gesture.numberOfTouchesRequired = 1
            self.addGestureRecognizer(gesture)
            self.isUserInteractionEnabled = true
        }
        self.actionOnTouch = closure
    }

    @objc internal func actionOnTouchUpInside() {
        actionOnTouch?(self)
    }
    
    // Override -intrinsicContentSize: for Auto layout code
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += insets.vertical
        contentSize.width += insets.horizontal
        return contentSize
    }
    
    // Override -sizeThatFits: for Springs & Struts code
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var contentSize = super.sizeThatFits(size)
        contentSize.height += insets.vertical
        contentSize.width += insets.horizontal
        return contentSize
    }

}
