//
//  NIBLoadable.swift
//  mMsgr
//
//  Created by Aung Ko Min on 16/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import UIKit

// Reusuable
protocol ReusableView: class {
    static var reuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

// NIB Loadable
protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
    
    func register<T: UICollectionReusableView>(_: T.Type, forSupplementaryViewOfKind elementKind: String)
         where T: ReusableViewWithDefaultIdentifierAndKind { register(T.self, forSupplementaryViewOfKind: elementKind,
                      withReuseIdentifier: T.reuseIdentifier)
     }
     
    
     func dequeueReusableSupplementaryViewOfKind<T: UICollectionReusableView> (elementKind: String,
                                                                               forIndexPath indexPath: IndexPath)  -> T
         where T: ReusableViewWithDefaultIdentifierAndKind {
             guard let reusableView = dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else { fatalError(String(format: "%@%@", "Could not dequeue reusable view of kind \(elementKind)", "with identifier: \(T.reuseIdentifier)"))}
             return reusableView
     }
}

extension UITableView {
    
    func register<T: UITableViewCell>(_: T.Type) where T: ReusableView {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func register<T: UITableViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
}


protocol ReusableViewWithDefaultIdentifierAndKind: ReusableView  {
    static var defaultElementKind: String { get }
}
extension ReusableViewWithDefaultIdentifierAndKind where Self: UIView {
    static var defaultElementKind: String {
        let className = String(describing: self)
        return "\(className)DefaultElementKind"
    }
}
