//
//  RoomModel.swift
//  mMsgr
//
//  Created by Aung Ko Min on 6/3/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation

struct RoomModel {
    
    let id: String
    let name: String
    let isGroup: Bool
}

extension RoomModel: FirestoreModel, Encodable {
    
    init?(modelData: FirestoreModelData) {
        self.init(dic: modelData.data)
    }
    
    init?(dic: [String: Any]?) {
        guard
            let dic = dic,
            let id = dic["id"] as? String,
            let name = dic["name"] as? String,
            let isGroup = dic["isGroup"] as? Bool
            else { return nil }
        self.init(id: id, name: name, isGroup: isGroup)
    }
    
    init(room: Room) {
        self.init(id: room.id ?? "", name: room.name ?? "", isGroup: room.isGroup)
    }
}
