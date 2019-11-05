//
//  SectionBackgroundDecorationView.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/8/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit


final class SectionBackgroundDecorationView: UICollectionReusableView, ReusableViewWithDefaultIdentifierAndKind {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        backgroundColor = UIColor.tertiarySystemBackground
        self.cornerRadius = 9
        
    }
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
}

extension SectionBackgroundDecorationView {
    func configure() {
        
    }
}
