import UIKit

extension UIAlertController {
    
    /// Add a Text Viewer
    ///
    /// - Parameters:
    ///   - text: text kind
    
    func addTextViewer(text: TextViewerViewController.Kind) {
        let textViewer = TextViewerViewController(text: text)
        set(vc: textViewer)
    }
}

final class TextViewerViewController: UIViewController {
    
    enum Kind {
        case text(String?)
        case attributedText(NSAttributedString?)
        case attributedTextBlock([AttributedTextBlock])
    }
    
    fileprivate var text: [AttributedTextBlock] = []
    
    fileprivate lazy var textView: UITextView = {
        $0.isEditable = false
        $0.isSelectable = true
        $0.backgroundColor = nil
        $0.font = UIFont.preferredFont(forTextStyle: .body)
        return $0
    }(UITextView())
    
    struct UI {
        static let height: CGFloat = UIScreen.main.bounds.height * 0.8
        static let vInset: CGFloat = 16
        static let hInset: CGFloat = 16
    }
    
    
    init(text kind: Kind) {
        super.init(nibName: nil, bundle: nil)
        
        switch kind {
        case .text(let x):
            
            textView.font = x?.EXT_isMyanmarCharacters == true ? UIFont.bodyMyanmarFont : UIFont.bodyFont
            textView.text = x
        case .attributedTextBlock(let x):
            textView.attributedText = x.map { $0.text }.joined(separator: "\n")
        case .attributedText(let x):
            textView.attributedText = x
            
        }
        
        textView.textContainerInset = UIEdgeInsets(top: UI.hInset, left: UI.vInset, bottom: UI.hInset, right: UI.vInset)
        
        //preferredContentSize.height = self.textView.contentSize.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override func loadView() {
        view = textView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            preferredContentSize.width = UIScreen.main.bounds.width * 0.618
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.scrollToTop()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize.height = textView.contentSize.height
        
    }
}
