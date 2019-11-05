//
//  DispatchQueueExtensions.swift
//  mMsgr
//
//  Created by Aung Ko Min on 26/9/17.
//  Copyright © 2017 Aung Ko Min. All rights reserved.
//

import Foundation
import Dispatch


// stolen from Kingfisher: https://github.com/onevcat/Kingfisher/blob/master/Sources/ThreadHelper.swift
extension DispatchQueue {
   
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}

typealias Task = (_ cancel : Bool) -> Void

@discardableResult func DispatchQueueDelay(_ time: TimeInterval, task: @escaping ()->()) ->  Task? {
    
    func dispatch_later(block: @escaping ()->()) {
        let t = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    }
    var closure: (()->Void)? = task
    var result: Task?
    
    let delayedClosure: Task = {
        cancel in
        if let internalClosure = closure {
            if (cancel == false) {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    return result
}
