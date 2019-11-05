//
//  EncryptText.swift
//  mMsgr
//
//  Created by Aung Ko Min on 7/8/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import Foundation
import RNCryptor
// Encrypt
func EncryptText (messageId: String, string: String) -> String {

    let data = string.data(using: String.Encoding.utf8)

    let encryptedData = RNCryptor.encrypt(data: data!, withPassword: messageId)

    return encryptedData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))

}


// Decrypt
func DecryptText (messageId: String, string: String) -> String {

    let decryptor = RNCryptor.Decryptor(password: messageId)

    guard let encryptedData = NSData(base64Encoded: string, options: NSData.Base64DecodingOptions(rawValue: 0))  else {
        return "Decrption Error"
    }

    var message: NSString = ""

    do {

        let decryptedData = try decryptor.decrypt(data: encryptedData as Data)

        message = NSString(data: decryptedData, encoding: String.Encoding.utf8.rawValue)!

    } catch {

        print("Error Decoding Text : \(error)")

    }

    return message as String
}
