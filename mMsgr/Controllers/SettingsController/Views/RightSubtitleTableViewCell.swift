//
//  RightSubtitleTableViewCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 14/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//
import UIKit

final class RightSubtitleTableViewCell: UITableViewCell, ReusableView {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        imageView?.tintColor = UIColor.myAppWatermelon
        imageView?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy)
//        detailTextLabel?.font = UIFont.monoSpacedFont
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ setting: AppViewController.Setting) {
        accessoryView = setting.isSelectable ? UIImageView(image: UIImage(systemName: "square.and.pencil")) : nil
        
        textLabel?.text = setting.rawValue
        detailTextLabel?.text = setting.description
        imageView?.image = setting.image
    }
}
