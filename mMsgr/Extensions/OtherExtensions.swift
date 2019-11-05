//
//  OtherExtensions.swift
//  mMsgr
//
//  Created by Aung Ko Min on 21/10/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

extension Optional where Wrapped == String {
    var emptyIfNil: String {
        return self ?? String()
    }
}


extension Bundle {
    var version: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

extension URL {
    static var mMsgr_profilePhotoURL: URL? {
        return URL(string: "https://firebasestorage.googleapis.com/v0/b/mmsgr-1b7a6.appspot.com/o/Profile%20Photo%2Fdefault.jpg?alt=media&token=7640733a-bbda-4abd-9b58-346ea057a503")
    }
}

extension Equatable {
    func shareWithMenu() {
        let activity = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        UIApplication.topViewController()?.present(activity, animated: true, completion: nil)
    }
}




extension FileManager {
    func clearTemp() {
        do {
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try FileManager.default.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
