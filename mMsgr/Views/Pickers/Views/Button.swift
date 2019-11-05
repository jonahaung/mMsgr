import UIKit

class MyButton: UIButton {
    
    typealias Action = (MyButton) -> Swift.Void
    
    fileprivate var actionOnTouch: Action?
    
    
    func action(_ closure: @escaping Action) {
        if actionOnTouch == nil {
            addTarget(self, action: #selector(MyButton.actionOnTouchUpInside), for: .touchUpInside)
        }
        self.actionOnTouch = closure
    }
    
    @objc internal func actionOnTouchUpInside() {
        actionOnTouch?(self)
    }
}


