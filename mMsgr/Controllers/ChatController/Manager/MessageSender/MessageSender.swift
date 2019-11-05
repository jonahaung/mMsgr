//
//  MessageSender.swift
//  mMsgr
//
//  Created by Aung Ko Min on 24/11/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import OneSignal
import CoreData


final class MessageSender: NSObject {
    
    class var shared: MessageSender {
        struct X { static let instance = MessageSender() }
        return X.instance
    }
    
    lazy var preferredHighQualityTranslation = userDefaults.currentBoolObjectState(for: userDefaults.usesHighQualityTranslation)
    
    private let queue: OperationQueue = {
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .default
        return $0
    }(OperationQueue())
    
    private let firebaseDatabaseReference = Database.database().reference().child(MyApp.Translate.rawValue)
    private lazy var googleTranslate = GoogleTranslator.shared
    private lazy var mymemoryTranslate = MyMemoryTranslation.shared
    private lazy var linkDetector: NSDataDetector? = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    private var incomingDatabaseReference: DatabaseReference?
    private var msgDatabaseReference = Database.database().reference().child("Message")
    private var databaseObserver: UInt?
    
    deinit {
        queue.cancelAllOperations()
        stopObservingIncomingMessages()
        print("Deinit : Message Sender")
    }
    
    
}

// Incoming

extension MessageSender {
    
    func startObservingIncomingMessages(user: User) {
        if databaseObserver != nil {
            stopObservingIncomingMessages()
        }
        incomingDatabaseReference = Database.database().reference().child("Message").child(user.uid)

        databaseObserver = incomingDatabaseReference?.observe(.value, with: { [weak self] snapshot in
            guard let `self` = self else { return }
            guard snapshot.exists() else { return }

            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
               
                let datas = snaps.map{ $0.value as? [String: Any]}.compactMap{ $0 }.map{ MsgModel(dic: $0 )}.compactMap{ $0 }
                guard datas.count > 0 else { return }
                let context = PersistenceManager.sharedInstance.editorContext
                context.performAndWait { [weak self] in
                    guard let `self` = self else { return }
                    datas.forEach{
                         self.createIncomingMessage($0, context: context)
                    }
                    context.saveIfHasChnages()
                    self.incomingDatabaseReference?.removeValue()
                    SoundManager.playSound(tone: .receivedMessage)
                }
            }
        })
    }
    
    func stopObservingIncomingMessages() {
        queue.cancelAllOperations()
        guard let observer = databaseObserver else { return }
        incomingDatabaseReference?.removeObserver(withHandle: observer)
        databaseObserver = nil
    }
    
    func createIncomingMessage(_ model: MsgModel, context: NSManagedObjectContext) {
        
        guard let msgId = UUID(uuidString: model.id), Message.count(in: context, includePending: true, predicate: Message.predicate(forID: msgId)) == 0 else { return }
        let fModel = model.friCodable
        
        let friend: Friend = Friend.get(fModel, context: context)
        let room = Room.get(fModel, context: context)
        if room.member != friend {
            room.member = friend
        }
        
        let msg = Message(context: context)
        msg.id = msgId
        msg.date = Date(timeIntervalSince1970: model.date)
        msg.msgType = model.type
        msg.isSender = false
        msg.y = model.y
        msg.x = model.x
        msg.text = model.text
        msg.text2 = model.translatedText
        msg.language = model.text.language
        msg.language2 = model.translatedText?.language
        msg.section = msg.getSectionDate(for: room.lastMsg)
        msg.sender = friend
        msg.room = room
        msg.lastMsgPoiter = room
    }

    
}

// Outgoing

extension MessageSender {
    
    func create(_ roomId: NSManagedObjectID?, type: MsgType, id: UUID, text: String, translatedText: String?, _ turple: (Double, Double) = (0,0)){
        guard let objectID = roomId else { return }
    
        let context = PersistenceManager.sharedInstance.editorContext
        context.performAndWait { [weak self, unowned context] in
            guard let `self` = self else { return }
            guard let room = context.object(with: objectID) as? Room, let friend = room.member else { return }
            let msg = Message(context: context)
            msg.id = id
            msg.date = Date()
            msg.isSender = true
            msg.text = text
            msg.text2 = translatedText
            msg.language = text.language
            msg.language2 = translatedText?.language
            msg.msgType = type.rawValue
            msg.x = turple.0
            msg.y = turple.1
            msg.section = msg.getSectionDate(for: room.lastMsg)
            msg.room = room
            msg.lastMsgPoiter = room
            context.saveIfHasChnages()
            
            let friendModel = FriendModel(friend: friend)
            guard let msgModel = msg.msgCodable else { return }
            if type == .Audio || type == .Photo || type == .Video {
                msg.uploadMedia()?.observe(.success, handler: { (snap) in
                    if let progress = snap.progress {
                        if progress.isFinished == true {
                            self.send(msgModel: msgModel, text: text, friendModel: friendModel)
                        }
                    }
                })
            }else {
                self.send(msgModel: msgModel, text: text, friendModel: friendModel)
            }
        }

    }
    
    private func send(msgModel: MsgModel, text: String, friendModel: FriendModel) {
        
        guard
            var dictionary = msgModel.dictionary,
            let user = Auth.auth().currentUser,
            let pushId = friendModel.pushId,
            let senderName = user.displayName,
            let roomId = msgModel.roomModel?.id
            else { return }
        
        let memberId = friendModel.uid
        
        dictionary["date"] = ServerValue.timestamp()
        if isDeveloperTesting {
            SoundManager.playSound(tone: .sendMessage)
            return
        }
        msgDatabaseReference.child(memberId).child(msgModel.id).setValue(dictionary) { (err, _) in
            if err == nil {
                let data: [AnyHashable : Any] = [
                    "include_player_ids": [pushId],
                    "contentAvailable": 1,
                    "contents": ["en": text],
                    "headings": ["en": senderName],
                    "data": ["roomId": roomId],
                    "subtitle": ["en": ""],
                    "ios_badgeType": "Increase",
                    "ios_sound": "mainTone.wav",
                    "thread-id": roomId,
                    "ios_badgeCount": 1
                ]
                OneSignal.postNotification(data, onSuccess: { result in
                    SoundManager.playSound(tone: .sendMessage)
                    if let result = result {
                        print(result)
                    }
                }) { err in
                    if let err = err {
                        print(err)
                    }
                }
                
            }
        }
    }
    
    
    
    func lormReply() {
        
        guard let x = GlobalVar.currentRoom else { return }
        queue.addOperation {
            let context = PersistenceManager.sharedInstance.editorContext
            context.performAndWait {
                guard let room = context.object(with: x.objectID) as? Room, let friend = room.member else { return }
                let friendModel = FriendModel(friend: friend)
                
                var words = [Lorem.shortTweet, Lorem.emailAddress, Lorem.paragraph, Lorem.fullName, Lorem.sentence, Lorem.url, Lorem.title]
                words.shuffle()
                
                let text = words.first ?? Lorem.word
                
                let msgModel = MsgModel(id: UUID().uuidString, type: 1, date: Date().timeIntervalSince1970, text: text, x: 0, y: 0, friCodable: friendModel, translatedText: nil, roomModel: nil)
                self.createIncomingMessage(msgModel, context: context)
                context.saveIfHasChnages()
            }
        }
    }
    
    private var isDeveloperTesting: Bool {
        return GlobalVar.currentUser?.displayName == "MMSGR" && GlobalVar.currentRoom?.name == "Jonah Aung"
    }
}

// Text

extension MessageSender {
    
    private typealias TranslatePair = [String: String]
    
    func SendTextMessage(for roomID: NSManagedObjectID?, text: String, canTranslate: Bool) {
        let text = text.trimmed
        guard isNotRichLink(text: text, roomId: roomID) else { return }
        guard canTranslate else {
            queue.addOperation {[weak self] in
                guard let `self` = self else { return }
                self.create(roomID, type: .Text, id: UUID(), text: text, translatedText: nil)
            }
            return
        }
        let language = text.language ?? "en"
        let isMyanmar = language == "my"
        
        let textArray = isMyanmar ? text.components(separatedBy: CharacterSet.myaLineEnding) : text.components(separatedBy: .engLineEnding)
        
        let lines = textArray.map{ $0.trimForFirebase }.filter{ !$0.isWhitespace }
        
        var results = TranslatePair()
        
        let group = DispatchGroup()
        
        lines.forEach { line in
            
            group.enter()
            
            if let finalResult = Translate.fetch(source: line, in: PersistenceManager.sharedInstance.editorContext)?.destination {
                results[line] = finalResult
                group.leave()
            } else {
                findAtDatabase(language: language, text: line) { [weak self] (remoteResult) in
                    guard let `self` = self else {
                        group.leave()
                        return
                    }
                    if let remoteResult = remoteResult {
                        results[line] = remoteResult
                        group.leave()
                    } else {
                        let sentence = Sentence(line)
                        self.findAtMyMemory(sentence: sentence) { [weak self] (result) in
                            guard let `self` = self else {
                                group.leave()
                                return
                            }
                            if let result = result {
                                results[line] = result
                                group.leave()
                            } else {
                                self.findAtGoogle(sentence: sentence) {(googleResult) in
                                    results[line] = googleResult
                                    group.leave()
                                }
                            }
                        }
                        
                        
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            let resultText = results.values.joined(separator: " ")
            self.queue.addOperation {[weak self] in
                guard let `self` = self else { return }
                self.create(roomID, type: .Text, id: UUID(), text: resultText, translatedText: text)
            }
        }
        
    }
    
    private func findAtDatabase(language: String, text: String, completion: @escaping ((String?)->Void)) {
        firebaseDatabaseReference.child(language).child(text).observeSingleEvent(of: .value, with: { snap in
            if snap.exists(), let result = snap.value as? String {
                completion(result)
            } else {
                completion(nil)
            }
        })
    }
    
    private func findAtGoogle(sentence: Sentence, completion: @escaping ((String)->Void)) {
        
        googleTranslate.translate(sentence.text, sentence.fromLanguage, sentence.toLanguage) {[weak self] (found, err) in
            guard let `self` = self else {
                completion(sentence.text)
                return
            }
            if let err = err {
                Log(err)
                completion(sentence.text)
                return
            }
            
            if let found = found {
                let corrected = TextCorrector.shared.correct(text: found)
                let toUpload = corrected.trimForFirebase
                self.firebaseDatabaseReference.child(sentence.fromLanguage).child(sentence.text).setValue(toUpload)
                self.firebaseDatabaseReference.child(sentence.toLanguage).child(toUpload).setValue(sentence.text)
                completion(corrected)
            }else {
                completion(sentence.text)
            }
            
        }
    }
    
    private func findAtMyMemory(sentence: Sentence, completion: @escaping ((String?)->Void)) {
        if preferredHighQualityTranslation {
            completion(nil)
        }else {
            mymemoryTranslate.translate(text: sentence.text, from: sentence.fromLanguage, to: sentence.toLanguage) { [weak self] (found, err) in
                guard let `self` = self else {
                    completion(nil)
                    return
                }
                if let err = err {
                    Log(err)
                    completion(nil)
                    return
                }
                
                guard let found = found else {
                    completion(nil)
                    return
                }
                
                let corrected = TextCorrector.shared.correct(text: found)
                let toUpload = corrected.trimForFirebase
                
                self.firebaseDatabaseReference.child(sentence.fromLanguage).child(sentence.text).setValue(toUpload)
                self.firebaseDatabaseReference.child(sentence.toLanguage).child(toUpload).setValue(sentence.text)
                
                completion(corrected)
            }
        }
    }
}

// RichLink

extension MessageSender {
    
    func isNotRichLink(text: String, roomId: NSManagedObjectID?) -> Bool {
        guard let matches = linkDetector?.matches(in: text, options: .reportCompletion, range: text.nsRange(of: text)) else { return false }
        let urls = matches.map{ $0.url }.compactMap{ $0 }
        guard urls.count > 0 else { return true}
        let trimmed = urls.map{ text.replace(target: $0.absoluteString, withString: String())}.joined().trimmed
        urls.asyncForEach(completion: {
            if !trimmed.isWhitespace {
                self.queue.addOperation { [weak self] in
                    guard let `self` = self else { return }
                    self.create(roomId, type: .Text, id: UUID(), text: trimmed, translatedText: nil)
                }
            }
        }) { (url, next) in
            self.sendRichLink(roomId: roomId, url: url)
            next()
        }
        return false
    }
    
    func sendRichLink(roomId: NSManagedObjectID?, url: URL) {
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            self.create(roomId, type: .RichLink, id: UUID(), text: url.absoluteString, translatedText: nil)
        }
    }
}

// Photo


extension MessageSender {
    
    func sendPhotoMessage(roomID: NSManagedObjectID?, image: UIImage) {
        
        queue.addOperation {[weak self] in
            guard let `self` = self else { return }
            let msgId = UUID()
            guard
                let originalResizedImage = image.scaledToSafeUploadSize,
                
                let originalData = originalResizedImage.pngData()
                else { return }
            
            guard let originalUrl = DownloadManager.localFileURLFor(msgId.uuidString) else { return }
            let originalSize = originalResizedImage.size
            let width = Int(230)
            let height = Int(ceil(CGFloat(width) / originalSize.width * originalSize.height))
            let size = CGSize(width: width, height: height)
            
            do {
                try originalData.write(to: originalUrl)
                self.create(roomID, type: .Photo, id: msgId, text: MsgType.Photo.text, translatedText: nil, (Double(size.width), Double(size.height)))
            }catch {
                print(error)
            }
        }
        
        
    }
}

// Video


extension MessageSender {
    
    func sendVideoMessage(roomID: NSManagedObjectID?, url: URL) {
        
        guard let thumbImage = url.getVideoThumbnail() else { return }
        
        queue.addOperation {[weak self] in
            guard let `self` = self else { return }
            let msgId = UUID()
            let size = thumbImage.size
            let x = Double(size.width)
            let y = Double(size.height)
            
            guard
                let videoData = NSData(contentsOfFile: url.path)
                else { return }
            
    
            guard let originalUrl = DownloadManager.localFileURLFor(msgId.uuidString+DataType.MOV.rawValue) else { return }
            
            do {
                try videoData.write(to: originalUrl, options: .atomic)
                self.create(roomID, type: .Video, id: msgId, text: MsgType.Video.text, translatedText: nil, (x, y))
            }catch {
                print(error)
            }
        }
        
    }
}



// Audio


extension MessageSender {
    
    func sendAudioMessage(roomID: NSManagedObjectID?, url: URL) {
        
        queue.addOperation {[weak self] in
            guard let `self` = self else { return }
            let msgId = UUID()
            
            guard
                let audioData = NSData(contentsOf: url) else { return }
            guard let originalUrl = DownloadManager.localFileURLFor(msgId.uuidString+DataType.M4A.rawValue) else { return }
            do {
                try audioData.write(to: originalUrl, options: .atomic)
                self.create(roomID, type: .Audio, id: msgId, text: MsgType.Audio.text, translatedText: nil, (0, 0))
            } catch {
                print(error)
            }
        }
        
    }
}


// Location


extension MessageSender {
    
    func sendLocationMessage(roomID: NSManagedObjectID?, lat: Double, long: Double, place: String?) {
        queue.addOperation { [weak self] in
            guard let `self` = self else { return }
            self.create(roomID, type: .Location, id: UUID(), text: place ?? "Location", translatedText: nil, (lat, long))
        }
    }
}


// Gif


extension MessageSender {
    
    func sendGifMessage(roomID: NSManagedObjectID?, fileNameWithType: String, imageSize: CGSize) {
        queue.addOperation {[weak self] in
            guard let `self` = self else { return }
            self.create(roomID, type: .Gif, id: UUID(), text: MsgType.Gif.text, translatedText: fileNameWithType, (Double(imageSize.width), Double(imageSize.height)))
        }
        
    }
}


// Face


extension MessageSender {
    
    func sendSmileMessage(roomID: NSManagedObjectID?, text: String, isSmile: Bool) {
        queue.addOperation {[weak self] in
            guard let `self` = self else { return }
            let faceName = isSmile ? "smile.gif" : "notSmile.gif"
            let width = Double(GlobalVar.vSCREEN_WIDTH - 100)
            
            let msgId = UUID()
            self.create(roomID, type: .Face, id: msgId, text: MsgType.Face.text, translatedText: faceName, (width, width))
        }
        
    }
}
