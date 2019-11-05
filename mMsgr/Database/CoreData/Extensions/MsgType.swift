//
//  MsgType.swift
//  mMsgr
//
//  Created by Aung Ko Min on 24/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit


enum MsgType: Int16, RawRepresentable {
    
    case RichLink, Text, Photo, Video, Audio, Location, Gif, Face, System
    
    var text: String {
        switch self {
        case .Photo:
            return "Photo Message"
        case .Video:
            return "Video Message"
        case .Audio:
            return "Audio Message"
        case .Gif:
            return "Gif Message"
        case .Face:
            return "Smaile Message"
        default:
            return "nil"
        }
    }
    
    var storageDirectory: StorageDirectory {
        switch self {
        case .Photo:
            return .PhotoMessage
        case .Video:
            return .VideoMessage
        case .Audio:
            return .AudioMessage
        case .Gif:
            return .Gif
        case .Face:
            return .Face
        default:
            return .ProfilePhoto
        }
    }
    
}
enum StorageDirectory: String {
    case ProfilePhoto = "Profile Photo"
    case PhotoMessage = "Photo Message"
    case AudioMessage = "Audio Message"
    case VideoMessage = "Video Message"
    case LocationMessage = "Location Message"
    case Gif = "Gif"
    case Face = "Face"
}
