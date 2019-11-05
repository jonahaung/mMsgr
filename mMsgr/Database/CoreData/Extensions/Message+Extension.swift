//
//  Message+Extension.swift
//  mMsgr
//
//  Created by Aung Ko Min on 27/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//
import UIKit
import FirebaseStorage
import FirebaseDatabase
import CoreData
import LinkPresentation


internal let paragraphStyle: NSMutableParagraphStyle = {
    $0.lineBreakMode = .byWordWrapping
    return $0
}(NSMutableParagraphStyle())

private var leftAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle]
private var rightAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemBackground, .paragraphStyle: paragraphStyle]
private var linkAttributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]

internal let dateTimeAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular), .foregroundColor: UIColor.tertiaryLabel]

internal let languageAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .footnote), .foregroundColor: UIColor.myAppYellow]


extension Message {
    
    static func predicate(forID id: UUID) -> NSPredicate {
        return NSPredicate(format: "id == %@", id as CVarArg)
    }
    
    func getAttributedText() -> NSAttributedString {
        guard msgType == 1 else { return NSAttributedString() }
        let font = textIsMyanmar ? UIFont.bodyMyanmarFont : UIFont.bodyFont
        var attributes = isSender ? rightAttributes : leftAttributes
        attributes.updateValue(font, forKey: .font)
        
        let attrStr = NSMutableAttributedString(string: text, attributes: attributes)
    
        let range = NSRange(location: 0, length: attrStr.length)
        
        for prase in  RegexParser.getElements(from: text, with: RegexParser.mentionPattern, range: range) {
            attrStr.addAttributes(linkAttributes, range: prase.range)
        }
        
        for prase in  RegexParser.getElements(from: text, with: RegexParser.hashtagPattern, range: range) {
            attrStr.addAttributes(linkAttributes, range: prase.range)
        }
        
        
        
        if !isSender {
            
            if isTranslateMsg {
                let from = language2?.capitalized ?? "En"
                let to = language?.capitalized ?? "My"
                let string = " \(from)-\(to) "
                
                attrStr.append(NSAttributedString(string: string, attributes: languageAttributes))
            }
            let dateString = NSAttributedString(string: " \(date.timeString(ofStyle: .short).withoutSpacesAndNewLines)", attributes: dateTimeAttributes)
            attrStr.append(dateString)
        }
        
        
        
        return attrStr
    }
    
    func getSectionDate(for msgBefore: Message?) -> Int64 {
        var new = Int64(date.timeIntervalSince1970)
        
        guard let before = msgBefore else { return  new}
        
        let old = before.section
        if new == old {
            date = date.addingTimeInterval(1)
            new = Int64(date.timeIntervalSince1970)
        }
        
        guard self.msgType == before.msgType && isSender == before.isSender else { return new }
        
        return self.date.timeIntervalSince(before.date) > 180 ? new : old
    }
    
    var textIsMyanmar: Bool {
        return language == "my"
    }
    var isTranslateMsg: Bool {
        return text2 != nil
    }

    var messageType: MsgType {
        return MsgType(rawValue: msgType) ?? .Text
    }
    
    func firebaseStorageRef() -> StorageReference? {
        let type = messageType
        switch type {
        case .Face, .Gif:
            let fileName = (text2 ?? text)
            return Storage.storageference(for: fileName, type: type.storageDirectory)
        default:
            return Storage.storageference(for: id.uuidString, type: messageType.storageDirectory)
        }
    }
    
    func firebaseDatabaseRef(for uid: String) -> DatabaseReference {
        return Database.database().reference().child("Message").child(uid).child(id.uuidString)
    }
    
    
    var msgCodable: MsgModel? {
        return MsgModel(msg: self)
    }
    
    func mediaSize() -> CGSize {
        let type = messageType
        switch type {
        case .Location:
            return CGSize(220)
        case .Audio:
            return CGSize(150)
        case .RichLink:
            return CGSize(width: 250, height: 300)
        default:
           return CGSize(width: x, height: y)
        }
    }
}

extension Message {
    
    var mediaURL: URL? {
        switch messageType {
        case .Video:
            return docURL.appendingPathComponent(id.uuidString + DataType.MOV.rawValue)
        case .Audio:
            return docURL.appendingPathComponent(id.uuidString + DataType.M4A.rawValue)
        default:
            return docURL.appendingPathComponent(id.uuidString)
        }
    }
    var videoThumbnilURL: URL? {
        return msgType == MsgType.Video.rawValue ? docURL.appendingPathComponent(id.uuidString+id.uuidString) : nil
    }
}
extension Storage {
    static func storageference(for fileName: String, type: StorageDirectory) -> StorageReference {
        return  storage().reference(forURL: "gs://mmsgr-1b7a6.appspot.com/\(type.rawValue)/"+fileName.trimmed)
    }
    
}


extension Message {
    
    func uploadMedia() -> StorageUploadTask? {
        
        guard
            isSender,
            let storageRef = firebaseStorageRef(),
            let fileURL = self.mediaURL
            else { return nil }
    
        if GlobalVar.currentUser?.isAdmin == true && room?.id == "UXXao5cfLogTJau9LTdokdg35Eb2eQKVg0NSGgd8dljvGM0iDQfo1K43" {
            return nil
        }
    
        return storageRef.putFile(from: fileURL)
    }
}

extension Message {
    func getRichLinkMetadata() -> LPLinkMetadata? {
        guard let url = mediaURL else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: LPLinkMetadata.self, from: data)
        }catch {
            Log(error)
            return nil
        }
    }
    
    func retriveRichLinkMetadata(_ url: URL, _ completion: @escaping (LPLinkMetadata?) -> ()) {
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { (metadata, err) in
            if let err = err {
                print(err)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            if let meta = metadata, let localURL = self.mediaURL {

                meta.store(at: localURL)
                DispatchQueue.main.async {
                    completion(meta)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func delete() {
        
        let context = PersistenceManager.sharedInstance.editorContext
        context.performAndWait {
            if let obj = context.object(with: objectID) as? Message {
                obj.msgType = 1
                obj.id = UUID()
                obj.text = "   "
                context.saveIfHasChnages()
            }
        }
        
        
    }
}
