//
//  SwitchObject.swift
//  FalconMessenger
//
//  Created by Roman Mizin on 8/12/18.
//  Copyright © 2018 Roman Mizin. All rights reserved.
//

import UIKit

class SwitchObject: NSObject {
  
  var state: Bool! {
    didSet {
      guard defaultsKey != nil else { return }
      userDefaults.updateObject(for: defaultsKey, with: state)
    }
  }
  var defaultsKey: String!
  
  init(state: Bool, defaultsKey: String ) {
    super.init()
    self.state = state
    self.defaultsKey = defaultsKey
  }
}
