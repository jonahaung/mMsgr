//
//  EmptyReusableView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 16/4/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

class ReusableSupplementryView: UICollectionReusableView, ReusableViewWithDefaultIdentifierAndKind {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    func willDisplayView() {}
    
    func didEndDisplayingView() {}

}
