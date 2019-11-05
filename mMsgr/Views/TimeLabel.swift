//
//  TimeLabel.swift
//  mMsgr
//
//  Created by Aung Ko Min on 29/4/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class TimeLabel: UIImageView {
    
    var insets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 5, right: 8)
    var text: String? {
        didSet {
            guard oldValue != text else { return }
            label.text = text
            label.sizeToFit()
            let labelSize = label.bounds.size
            self.size = CGSize(width: labelSize.width + insets.horizontal, height: labelSize.height + insets.vertical)
            label.center = self.bounds.center
            if let x = self.superview {
                center.x = x.center.x
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundImage = UIImage(named: "labelBackground")!
        let vertical = (backgroundImage.size.height / 2).rounded()
        let horizontal = (backgroundImage.size.width / 2).rounded()
        image = backgroundImage.resizableImage(withCapInsets: UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal), resizingMode: .stretch)
        addSubview(label)
    }
    
    private let label: UILabel = {
        $0.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .medium)
        $0.textColor = .darkText
        return $0
    }(UILabel())
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
