//
//  GlobalStorage.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import FirebaseAuth

let GlobalVar = GlobalStorage()

internal class GlobalStorage {

    var isZawGyiPreferred = false
    
    var kAUDIO_MAX_DURATION: Double = 5
    let kVIDEO_MAX_DURATION = 50.0
    
    var currentUser: User? { return Auth.auth().currentUser }
    
    var vDISPLAY_NAME: String {
        return currentUser?.displayName?.firstWord ?? "Human"
    }
    let kTRANSLATE_MAX_CHARACTER: Int = 300
    
    var vSCREEN_WIDTH: CGFloat = {
        return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }()
    
    var updatesAnimationDuration: TimeInterval = 0.25
    let animationOption: UIView.AnimationOptions = [.curveEaseIn, .beginFromCurrentState, .allowUserInteraction]
    var autoloadingFractionalThreshold: CGFloat = 0.05
    var mMsgr_standDisplayLimit = 50
    let bma_epsilon: CGFloat = 0.001

    var theme = Theme(themeValue: 1)
    var currentRoom: Room? {
        didSet {
            if let room = self.currentRoom {
                theme = Theme(themeValue: room.themeValue)
            }
        }
    }
    var focusedUserId: String?
}
