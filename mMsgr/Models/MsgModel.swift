//
//  MsgCodable.swift
//  mMsgr
//
//  Created by Aung Ko Min on 2/3/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Foundation

struct MsgModel {

    let id: String
    let type: Int16
    var date: TimeInterval
    let text: String
    let x: Double
    let y: Double
    let friCodable: FriendModel
    var translatedText: String?
    let roomModel: RoomModel?
}

extension MsgModel: Encodable {
    
    init?(msg: Message) {
        guard let user = GlobalVar.currentUser,
            let friCodable = FriendModel(user: user),
            let room = msg.room
            else {
                return nil
        }
        let date = Double(msg.date.timestamp())
        let id = msg.id.uuidString
        let text = EncryptText(messageId: id, string: msg.text)
        let type = msg.msgType
        let x = msg.x
        let y = msg.y
        
        var transText: String?
        
        if let translated = msg.text2 {
            transText = EncryptText(messageId: msg.id.uuidString, string: translated)
        }
        let roomModel = RoomModel(room: room)
        
        self.init(id: id, type: type, date: date, text: text, x: x, y: y, friCodable: friCodable, translatedText: transText, roomModel: roomModel)
    }
    
    init?(dic: [String: Any]) {
        
        guard let timeInterval = dic["date"] as? TimeInterval,
            let id = dic["id"] as? String,
            let text = dic["text"] as? String,
            let type = dic["type"] as? Int16,
            let x = (dic["x"] as? NSNumber)?.doubleValue,
            let y = (dic["y"] as? NSNumber)?.doubleValue,
            let fcodable = FriendModel(dic: dic["friCodable"] as? [String: Any])
        
            else {
                return nil
        }
        let roomModel = RoomModel(dic: dic["roomModel"] as? [String: Any])
        let dateInDouble = timeInterval/1000
        var translated = dic[MyApp.translatedText.rawValue] as? String
        
        if let text = translated {
            translated = DecryptText(messageId: id, string: text)
        }
        let decryptedText = DecryptText(messageId: id, string: text)

        self.init(id: id, type: type, date: dateInDouble, text: decryptedText, x: x, y: y, friCodable: fcodable, translatedText: translated, roomModel: roomModel)
    }
}
