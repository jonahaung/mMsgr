//
//  ZawGyiConverter.swift
//  mMsgr
//
//  Created by Aung Ko Min on 15/4/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import Foundation

final class FontConverter {
    
    static var shared: FontConverter {
        struct Singleton {
            static let instance = FontConverter()
        }
        return Singleton.instance
    }
    
    
    private lazy var uniToZawGyiRule: [NSDictionary] = {
        if let path = Bundle.main.path(forResource: "ZawGyi", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options:[])
                return jsonResult as? [NSDictionary] ?? []
            } catch {
                return []
            }
        }
        return []
    }()
    
    private lazy var zawGyiToUniRule: [NSDictionary] = {
        if let path = Bundle.main.path(forResource: "Uni", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
                return jsonResult as? [NSDictionary] ?? []
            } catch {
                return []
            }
        }
        return []
    }()
    
    func convertFont(toZawGyi: Bool, text: String) -> String {
        let rule = toZawGyi ? uniToZawGyiRule : zawGyiToUniRule
        var output = text
        for dic in rule {
            guard let from = dic["from"] as? String, let to = dic["to"] as? String else { continue }
            let range = output.startIndex ..< output.endIndex
            
            output = output.replacingOccurrences(of: from, with: to, options: .regularExpression, range: range)
        }
        return output
    }
}
