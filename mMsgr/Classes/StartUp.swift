//
//  StartUp.swift
//  mMsgr
//
//  Created by Aung Ko Min on 13/9/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation
import CoreData

struct StartUp {
    
    static func loadMyanmarLanguageData() {
        Dic.deleteAllData() { _ in
            Translate.deleteAllData() { _ in
                Async.background {
                    guard let wordsUrl = Bundle.main.url(forResource: "uniqueWords", withExtension: ".txt"),
                        let pronUrl = Bundle.main.url(forResource: "pronunciations", withExtension: ".txt") else { return }
                    
                    do {
                        
                        let proString = try String(contentsOf: pronUrl)
                        let proLines = proString.components(separatedBy: "\n")
                        
                        
                        let string = try String(contentsOf: wordsUrl, encoding: .utf8)
                        let uniWords = string.components(separatedBy: .newlines)
                        let fontConverter = FontConverter.shared
                        let zawGyi = fontConverter.convertFont(toZawGyi: true, text: string)
                        let zawGyiWords = zawGyi.components(separatedBy: .newlines)
                        
                        let array = Array(zip(uniWords, zawGyiWords)).filter{ !$0.0.isWhitespace }
                        let count = array.count
                        let context = PersistenceManager.sharedInstance.editorContext
                        let date = Date()
                        
                        array.asyncForEach(completion: {
                            
                            proLines.asyncForEach(completion: {
                                context.saveIfHasChnages()
                                context.reset()
                                
                                Async.main {
                                    dropDownMessageBar.show(text: "Loaded \(count) words", duration: 5)
                                }
                            }) { (line, next) in
                                var segs = line.components(separatedBy: ",")
                                if let first = segs.first {
                                    segs.removeFirst()
                                    for sg in segs {
                                        let pro = Pronounce(context: context)
                                        pro.pronounce = first
                                        pro.word = sg.trimmed.urlEncoded
                                    }
                                }
                                next()
                            }
                           
                        }) { (item, next) in
                            let uniEncoded = item.0.urlEncoded
                            let zawGyiEncoded = item.1.urlEncoded
                            
                            let object = Dic(context: context)
                            object.text = uniEncoded
                            object.zawGyi = zawGyiEncoded
                            object.lastAccessedDate = date
                            object.rank = 0
                            object.length = Int64(uniEncoded.utf16.count)
                            object.info = "word"
                            next()
                        }
                        
                    }catch {
                        DispatchQueue.main.async {

                            print(error.localizedDescription)
                        }
                        
                    }
                }
            }
        }
        
    }
    
    static func configureWelcomeMessate() {
        
        let friModel = FriendModel(displayName: "mMsgr", phoneNumber: "+6588585229", pushId: "pushId", uid: "eQKVg0NSGgd8dljvGM0iDQfo1K43", photoURL: nil)
        let array: [String] = [
            "Hello \(GlobalVar.currentUser?.displayName ?? "")! How are you?", "Thank You for downloading our app.",
            "If you have any feedback or .. if you have anything to say about mMsgr, pls let us know from here.",
            "If you are new and you want to know more about mMsgr, pls click the link below to visit our facebook page",
            "Have a nice day",
            "Thank you"
        ]
        let context = PersistenceManager.sharedInstance.editorContext
        context.performAndWait {
            let friend = Friend.get(friModel, context: context)
            let room = Room.get(friModel, context: context)
            if friend.room != room {
                friend.room = room
            }

            array.forEach { text in
                let msg = Message(context: context)
                msg.id = UUID()
                msg.msgType = 1
                msg.isSender = false
                msg.date = Date()
                msg.text = text
                msg.section = msg.getSectionDate(for: room.getLastMessage())
                msg.room = room
                msg.sender = friend
                room.lastMsg = msg
            }
            let linkMsg = Message(context: context)
            linkMsg.id = UUID()
            linkMsg.msgType = MsgType.RichLink.rawValue
            linkMsg.isSender = false
            linkMsg.date = Date()
            linkMsg.text = "https://www.facebook.com/1889957847763002/posts/2527028557389258?sfns=mo"
            linkMsg.section = linkMsg.getSectionDate(for: room.getLastMessage())
            linkMsg.room = room
            linkMsg.sender = friend
            room.lastMsg = linkMsg
            
            context.saveIfHasChnages()
        }

    }
}
