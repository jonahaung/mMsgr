//
//  SwitchTableViewCell.swift
//  FalconMessenger
//
//  Created by Roman Mizin on 8/17/18.
//  Copyright © 2018 Roman Mizin. All rights reserved.
//

import UIKit

final class SwitchTableViewCell: DefaultTableViewCell {
    
    private let switchAccessory = SwitchBUtton()
    
    var switchTapAction: ((Bool)->Void)?
    
    override func setup() {
        super.setup()
        switchAccessory.thumbTintColor = .randomColor()
        switchAccessory.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
    }

    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        accessoryView = switchAccessory
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.textAlignment = .left
    }
    
    @objc func switchStateDidChange(_ sender: UISwitch) {
        switchTapAction?(sender.isOn)
    }
    
    func setupCell(object: SwitchObject) {
        switchAccessory.isOn = object.state

        switchTapAction = { (isOn) in
            object.state = isOn
        }
    }
    
    override func configure(_ setting: AppViewController.Setting) {
        super.configure(setting)
        if let object = setting.switchObject {
            setupCell(object: object)
        }
    }

}

