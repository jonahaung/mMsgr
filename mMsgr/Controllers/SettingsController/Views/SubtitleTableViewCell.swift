//
//  AboutMeTableCell.swift
//  mMsgr
//
//  Created by Aung Ko Min on 14/5/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

final class SubtitleTableViewCell: UITableViewCell, ReusableView, MainCoordinatorDelegatee {


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        
//        detailTextLabel?.textColor = UIColor.secondaryLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
    
}
