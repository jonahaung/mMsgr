//
//  Codable+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 2/3/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
