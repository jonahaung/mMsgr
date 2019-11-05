//
//  Theme.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

enum ThemeType: Int16, CaseIterable, RawRepresentable {
    case Random, Blue, BlueLight, Red, RedLight, Green, GreenLight, GreenDark, Magenta, Pink, Orange, Purple, PurpleDark, Yellow, YellowDark, Gray, Teal
    
    static let items: [ThemeType] = ThemeType.allCases
}

struct Theme {

    let type: ThemeType
    let mainColor: UIColor
    let tintColor: UIColor
    
    init(themeValue: Int16) {
        type = ThemeType(rawValue: themeValue) ?? .Blue
        
        switch type {
        case .Random:
            mainColor = UIColor.randomColor()
            tintColor = UIColor.blue
        case .Blue:
            mainColor = UIColor.systemBlue
            tintColor = UIColor.systemYellow
        case .BlueLight:
            mainColor = UIColor.myAppBlue
            tintColor = UIColor.systemYellow
        case .Red:
            mainColor = UIColor.systemRed
            tintColor = UIColor.systemIndigo
        case .RedLight:
            mainColor = UIColor.myAppWatermelon
            tintColor = UIColor.systemIndigo
        case .Green:
            mainColor = UIColor.myAppGreenApple
            tintColor = UIColor.link
        case .GreenLight:
            mainColor = UIColor.systemGreen
            tintColor = UIColor.link
        case .GreenDark:
            mainColor = UIColor.myappGreen
            tintColor = UIColor.systemIndigo
        case .Orange:
            mainColor = UIColor.systemOrange
            tintColor = UIColor.systemIndigo
        case .Magenta:
            mainColor = UIColor.myAppMagenta
            tintColor = UIColor.systemIndigo
        case .Pink:
            mainColor = UIColor.systemPink
            tintColor = UIColor.systemIndigo
        case .Purple:
            mainColor = UIColor.myAppPurpleLight
            tintColor = UIColor.systemYellow
        case .PurpleDark:
            mainColor = UIColor.systemPurple
            tintColor = UIColor.systemYellow
        case .Yellow:
            mainColor = UIColor.myAppYellow
            tintColor = UIColor.systemIndigo
        case .YellowDark:
            mainColor = UIColor.systemYellow.darker(by: 8)
            tintColor = UIColor.systemIndigo
        case .Gray:
            mainColor = UIColor.n1MidGreyColor
            tintColor = UIColor.systemIndigo
        case .Teal:
            mainColor = UIColor.systemTeal.darker(by: 9)
            tintColor = UIColor.systemIndigo
        }
    }
}

struct ThemeManager {
    
    static func applyTheme() {
        
        UIFont.applyCurrentTraitsCollection()
       
        let textField = UITextField.appearance()
        textField.font = UIFont.preferredFont(forTextStyle: .title3)
        textField.textAlignment = .center

        let tableView = UITableView.appearance()
        tableView.separatorInset = .zero

        let collectionView = UICollectionView.appearance()
        collectionView.backgroundColor = nil
    }
}


extension UIColor {
    static let myAppBlue = UIColor(named: "blue") ?? .blue
    static let myAppPowderBlue = UIColor(named: "powderBlue") ?? .blue

    static let myAppYellow = UIColor(named: "yellow") ?? .yellow
    
    static let myAppRed = UIColor(named: "red") ?? .red
    static let myAppWatermelon = UIColor(named: "watermelon") ?? .red
    static let myAppMagenta =  UIColor(named: "magenta") ?? .magenta
    static let myAppPink = UIColor(named: "pink") ?? .magenta
    
    static let myappGreen = UIColor(named: "green") ?? .green
    static let myAppMint = UIColor(named: "mint") ?? .green
    static let myAppGreenApple = UIColor(named: "greenApple") ?? .green
    
    static let myAppOrange = UIColor(named: "orange") ?? .orange

    static let myAppPurpleLight = UIColor(named: "purpleLight") ?? .purple

    static let n1MidGreyColor = UIColor(red: 144.0 / 255.0, green: 164.0 / 255.0, blue: 174.0 / 255.0, alpha: 1)
    static let n1DarkestGreyColor = UIColor(red: 38.0 / 255.0, green: 50.0 / 255.0, blue: 56.0 / 255.0, alpha: 1)
    static let n1DarkGreyColor = UIColor(red: 96.0 / 255.0, green: 125.0 / 255.0, blue: 139.0 / 255.0, alpha: 1)
    static let n1ActionBlueColor = UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1)
    static let n1AlmostWhiteColor = UIColor(red: 251.0 / 255.0, green: 252.0 / 255.0, blue: 253.0 / 255.0, alpha: 1)
    static let n1DarkerGreyColor = UIColor(red: 69.0 / 255.0, green: 90.0 / 255.0, blue: 100.0 / 255.0, alpha: 1)
    static let n1LightGreyColor = UIColor(red: 207.0 / 255.0, green: 216.0 / 255.0, blue: 220.0 / 255.0, alpha: 1)
    static let n1LighterGreyColor = UIColor(red: 233.0 / 255.0, green: 239.0 / 255.0, blue: 242.0 / 255.0, alpha: 1)
    static let n1PaleGreyColor = UIColor(red: 243.0 / 255.0, green: 247.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)

    
}

extension UIColor {
    static func random() -> UIColor {

        func random() -> CGFloat { return .random(in:0...1) }

        return UIColor(red:   random(), green: random(), blue:  random(),
                       alpha: 1.0)
    }
}

extension UIView {
    
    var isDarkMode: Bool {
        return traitCollection.userInterfaceStyle == .dark ? true : false
    }
    
}

extension UITraitCollection {
    
    static func applyCurrentTraitsCollection() {
        UIFont.applyCurrentTraitsCollection()
    }
}
