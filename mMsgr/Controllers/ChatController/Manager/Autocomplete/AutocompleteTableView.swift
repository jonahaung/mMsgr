//
//  AutocompleteTableView.swift
//  InputBarAccessoryView
//
//  Copyright © 2017-2018 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 10/4/17.
//

import UIKit

open class AutocompleteTableView: UITableView {
    
    open override var intrinsicContentSize: CGSize {
        let rows = CGFloat(numberOfRows(inSection: 0))
        let h = rows == 0 ? 0 : (rows * rowHeight) + contentInset.vertical
        return CGSize(width: UIView.noIntrinsicMetric, height: h)
    }
    
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .insetGrouped)
        bounces = true
        scrollsToTop = true
        contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        sectionHeaderHeight = 0
        sectionFooterHeight = 0
        showsVerticalScrollIndicator = false
        backgroundColor = nil
        separatorColor = .quaternarySystemFill
        rowHeight = 43
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        dropShadow()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
