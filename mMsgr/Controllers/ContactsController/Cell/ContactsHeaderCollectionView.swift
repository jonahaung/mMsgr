//
//  ContactsHeaderCollectionView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 10/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

class ContactsHeaderCollectionView: UICollectionReusableView, ReusableViewWithDefaultIdentifierAndKind {
    
    private let label: UILabel = {
        $0.textColor = .systemBackground
        $0.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .medium)
        return $0
    }(UILabel())
    
    var contentView: UIView = {
        $0.layer.backgroundColor = UIColor.systemRed.cgColor
        return $0
    }(UIView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.addSubview(label)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var titleText: String? {
        get {
            return label.text
        }
        set {
            guard titleText != newValue, let text = newValue else { return }
            let fontSize = (bounds.height) / 2.5
            if label.font.pointSize != fontSize {
                label.font = label.font.withSize(fontSize)
            }
            label.text = text
            label.sizeToFit()
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = bounds.inset(by: UIEdgeInsets(round: 5))
        label.center = contentView.bounds.center
        contentView.layer.cornerRadius = contentView.bounds.height/2
    }
    
//    override func draw(_ rect: CGRect) {
//         super.draw(rect)
//        let rect = rect.inset(by: UIEdgeInsets(round: 3))
//        let clipPath = UIBezierPath(ovalIn: rect).cgPath
//        let ctx = UIGraphicsGetCurrentContext()!
//        ctx.addPath(clipPath)
//        ctx.setFillColor(UIColor.link.cgColor)
//        ctx.closePath()
//        ctx.fillPath()
//    }
    
}

class EmptySupplementaryView: UICollectionReusableView, ReusableViewWithDefaultIdentifierAndKind {
    
   
}
public extension UIEdgeInsets {
    init(round: CGFloat) {
        self.init(top: round, left: round, bottom: round, right: round)
    }
}
