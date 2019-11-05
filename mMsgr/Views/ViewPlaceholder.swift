//
//  ViewPlaceholder.swift
//  Pigeon-project
//
//  Created by Roman Mizin on 11/6/17.
//  Copyright © 2017 Roman Mizin. All rights reserved.
//

import UIKit

enum ViewPlaceholderPriority: CGFloat {
    case low = 0.1
    case medium = 0.5
    case high = 1.0
}

enum ViewPlaceholderPosition {
    case top
    case center
}

enum ViewPlaceholderTitle: String {
    case emptyChat = "You don't have any active conversations yet."
    case emptyContacts = "Contacts List is Empty"
    case emptyRecents = "Recents List is Empty"
}

enum ViewPlaceholderSubtitle: String {
    case denied = "Please go to your iPhone Settings –– Privacy –– Contacts. Then select ON for mMsgr."
    case empty = "You can invite your friends to Flacon Messenger at the Contacts tab  "
    case emptyChat = "Please choose someone from Contacts, and send your first message."
    case emptyContacts = "Please have your contacts Synced (or) Add them manually."
    case emptyRecents = "Please go to 'Contacts' and select/add someone to start chatting.."
}

class ViewPlaceholder: CustomStackView, MainCoordinatorDelegatee {
    
    lazy var title: UILabel = {
        $0.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        $0.textColor = UIColor.secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.preferredMaxLayoutWidth = GlobalVar.vSCREEN_WIDTH - 100
        return $0
    }(UILabel())
    
    lazy var subtitle: UILabel = {
        $0.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: .medium)
        $0.textColor = UIColor.secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.preferredMaxLayoutWidth = GlobalVar.vSCREEN_WIDTH - 100
        return $0
    }(UILabel())
    
    var placeholderPriority: ViewPlaceholderPriority = .low
    
    
    override func setup() {
        super.setup()
        axis = .vertical
        alignment = .fill
        distribution = .fill
        spacing = UIStackView.spacingUseSystem
        translatesAutoresizingMaskIntoConstraints = false
        

        addArrangedSubview(title)
        addArrangedSubview(subtitle)
    }
    
    func add(for view: UIView, title: ViewPlaceholderTitle, subtitle: ViewPlaceholderSubtitle, priority: ViewPlaceholderPriority, position: ViewPlaceholderPosition) {
        
        guard priority.rawValue >= placeholderPriority.rawValue else { return }
        placeholderPriority = priority
        self.title.text = title.rawValue
        self.subtitle.text = subtitle.rawValue
        
        DispatchQueue.main.async {
            view.addSubview(self)
            self.centerInSuperview()
        }
    }
    
    func remove(from view: UIView, priority: ViewPlaceholderPriority) {
        guard priority.rawValue >= placeholderPriority.rawValue else { return }
        for subview in view.subviews where subview is ViewPlaceholder {
            DispatchQueue.main.async {
                subview.removeFromSuperview()
            }
        }
    }
}


class ChatPlaceHolder: CustomView {
    
    private lazy var label: UILabel = {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    
    
    var textBlock: [AttributedTextBlock] = [] {
        didSet {
            let attributedText = textBlock.map { $0.text }.joined(separator: "\n")
            let mutable = NSMutableAttributedString(attributedString: attributedText)
        
            let para = NSMutableParagraphStyle()
            para.alignment = .center
            para.lineBreakMode = .byWordWrapping
            para.lineSpacing = 2
            para.lineHeightMultiple = 1.3
            para.paragraphSpacing = 5
    
            mutable.addAttributes([.paragraphStyle: para, .foregroundColor: GlobalVar.theme.mainColor], range: NSRange(0..<attributedText.length))
            label.attributedText = mutable
            setNeedsDisplay()
        }
    }
    
    
    deinit {
        Log("has deinitialized")
    }
    
    override func setup() {
        super.setup()
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let labelSize = label.sizeThatFits(CGSize(width: bounds.width - 50, height: .infinity))
        label.frame = labelSize.bma_rect(inContainer: bounds, xAlignament: .center, yAlignment: .top, dx: 0, dy: 100)
    }
}
