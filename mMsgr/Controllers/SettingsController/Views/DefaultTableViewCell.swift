//
//  CenteredLabelTableCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 14/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

class DefaultTableViewCell: UITableViewCell, ReusableView {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
       setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        imageView?.tintColor = UIColor.systemBackground
        imageView?.layer.cornerRadius = 7
        
//        textLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
//        textLabel?.textColor = tintColor
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.layer.backgroundColor = UIColor.randomColor().cgColor
    }
    func configure(_ setting: AppViewController.Setting) {
        textLabel?.text = setting.rawValue
        imageView?.image = setting.image?.imageWithSize(size: CGSize(20), extraMargin: 5)?.withRenderingMode(.alwaysTemplate)
    }
}
