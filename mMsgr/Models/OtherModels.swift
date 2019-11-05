//
//  OtherModels.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

struct ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let maxLength = max(ScreenSize.width, ScreenSize.height)
    static let minLength = min(ScreenSize.width, ScreenSize.height)
    static let frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
}

struct DeviceType {
    static let iPhone4orLess = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength < 568.0
    static let iPhone5orSE = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength == 568.0
    static let iPhone678 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength == 667.0
    static let iPhone678p = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxLength == 736.0
    static let iPhoneX = UIDevice.current.userInterfaceIdiom == .phone && (ScreenSize.maxLength == 812.0 || ScreenSize.maxLength == 896.0)

    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.maxLength == 1024.0
    static let IS_IPAD_PRO = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.maxLength == 1366.0
}



enum DataType: String {
    case JPG = ".jpg"
    case PNG = ".png"
    case MOV = ".mov"
    case M4A = ".m4a"
    case GIF = ".gif"
}

enum MyApp : String {
    
    case unreadMessages = "unreadMessages"
    case firstLanguage = "firstLanguage"
    case secondLanguage = "secondLanguage"
    case kTranslateMode = "translateMode"

    case Message = "Message"
    case Friend = "Friend"
    case Translate = "Translate"
    case Dic = "Dic"
    case uid = "uid"
    case displayName = "displayName"
    case pushId = "pushId"
    case phoneNumber = "phoneNumber"
    case email = "email"
    case photoUrl = "photoUrl"
    case id = "id"
    case HasRead = "hasRead"
    case state = "state"
    case type = "type"
    case msgType2 = "emotionType"
    case x = "x"
    case y = "y"
    case ProfilePhoto = "Profile Photo"
    case Focused = "focused"
    case text = "text"
    case translatedText = "translatedText"
    case photo = "Photo Message"
    case audio = "Audio Message"
    case audios = "Audios"
    case video = "Video Message"
    case videos = "Videos"
    case location = "Location Message"
    case locations = "locations"
    case Users = "users"
    case Notifications = "NotiFications"
    case online = "online"
    case friends = "friends"
    case typing = "typing"
    case messageId = "messageId"
    case ThumbNil = "ThumbNil"
    case Original = "Original"
    case audioFileName = "audioFileName"
}
