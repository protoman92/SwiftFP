//
//  Timeout.swift
//  SwiftFP
//
//  Created by Hai Pham on 15/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Composable {
    
    /// Times out an operation with a timeout error. For the second curried
    /// parameter, provide the DispatchQueue to run the operation on. The
    /// result will be received on the calling thread, so beware which queue
    /// is passed in, because using the wrong dispatch queue may block forever.
    ///
    /// For example, it will block if both the calling queue and the perform
    /// queue are main. If both are backgrounds, or one main one background, it
    /// should be fine.
    ///
    /// - Parameter duration: A TimeInterval value.
    /// - Returns: A Composable instance.
    public static func timeout(_ duration: TimeInterval) -> (DispatchQueue) -> Composable<T> {
        return {(dq: DispatchQueue) -> Composable<T> in
            let sf: SupplierF<T> = {(s: @escaping Supplier<T>) -> Supplier<T> in
                return {
                    let mutex = NSLock()
                    var resultF: Supplier<T>?
                    var timedout = false
                    
                    let setTimedOut: (Bool) -> Void = {
                        mutex.lock()
                        defer { mutex.unlock() }
                        timedout = $0
                    }
                    
                    let setResult: (@escaping Supplier<T>) -> Void = {
                        mutex.lock()
                        defer { mutex.unlock() }
                        resultF = $0
                    }
                    
                    dq.async {
                        do {
                            let value = try s()
                            setResult({value})
                        } catch let e {
                            setResult({throw e})
                        }
                    }
                    
                    dq.asyncAfter(deadline: DispatchTime.now() + duration, execute: {
                        setTimedOut(true)
                    })
                    
                    while !timedout && resultF == nil {}
                    
                    if let resultF = resultF {
                        return try resultF()
                    } else {
                        throw FPError("Timed out after \(duration)")
                    }
                }
            }
            
            return Composable(sf)
        }
    }
}
