//
//  DownloadManager.swift
//  Rocket.Chat
//
//  Created by Aung Ko Min on 10/08/17.
//  Copyright © 2018 mMsgr. All rights reserved.
//

import Foundation

final class DownloadManager {

    static func filenameFor(_ url: String) -> String? {
        return url.components(separatedBy: "/").last
    }


    static func localFileURLFor(_ filename: String) -> URL? {
        return docURL.appendingPathComponent(filename)
//        if let docDirectory = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
//            return docDirectory.appendingPathComponent(filename)
//        }
//
//        return nil
    }

    static func fileExists(_ localUrl: URL) -> Bool {
        return FileManager.default.fileExists(atPath: localUrl.path)
    }


    static func download(url: URL, to localUrl: URL, completion: @escaping () -> Void) {
        // File may already exists
//        if fileExists(localUrl) {
//            completion()
//            return
//        }

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }

                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)

                    DispatchQueue.main.async {
                        completion()
                    }
                } catch let writeError {
                    print("error writing file \(localUrl) : \(writeError)")

                    DispatchQueue.main.async {
                        completion()
                    }
                }

            } else {
                print("Failure: %@", error?.localizedDescription ?? "")
            }
        }

        task.resume()
    }

}