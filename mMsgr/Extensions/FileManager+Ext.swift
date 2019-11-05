//
//  FileManager+Ext.swift
//  mMsgr
//
//  Created by Aung Ko Min on 15/12/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import Foundation


extension FileManager {
    
    public var EXT_documentsURL : URL {
        let paths = urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    public func EXT_lookupOrCreate(directoryAt url: URL) -> Bool {
        var isDirectory : ObjCBool = false

        if fileExists(atPath: url.path, isDirectory: &isDirectory) {
          
            if isDirectory.boolValue {
                return true
            }
            return false
        }

        do {
            try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
            return false
        }

        return true
    }
    
    public func Ext_safeURL(for fileName: String) -> URL? {
        
        let url = EXT_documentsURL.appendingPathComponent(fileName)
        
        var isDirectory : ObjCBool = false
        
        if fileExists(atPath: url.path, isDirectory: &isDirectory) {
            
            if isDirectory.boolValue {
                return url
            }
            return nil
        }
        
        do {
            try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            Log(error)
            return nil
        }
        
        return url
    }

   private  func delete_all (directory: StorageDirectory) {
        
        let documentsPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString)
        
        let path = documentsPath.appendingPathComponent(directory.rawValue + "/")
        var objcBool:ObjCBool = true
        do{
            if FileManager.default.fileExists(atPath: path, isDirectory: &objcBool) == true {
                try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
            }
        }catch{
            print(error.localizedDescription)
        }
    }

}
