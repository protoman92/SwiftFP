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
    /// result will be received on the calling thread, so it is important that
    /// the dispatch queue used to perform the operation does not coincide with
    /// the one that schedules this function.
    ///
    /// This is a very crude implementation. A better, more robust one may use
    /// a sync queue to check which event comes first.
    ///
    /// - Parameter duration: A TimeInterval value.
    /// - Returns: A Composable instance.
    public static func timeout(_ duration: TimeInterval) -> (DispatchQueue) -> Composable<T> {
        return {(dq: DispatchQueue) -> Composable<T> in
            let ff: FunctionF<T> = {(f: @escaping Function<T>) -> Function<T> in
                return {
                    dispatchPrecondition(condition: .notOnQueue(dq))
                    let mutex = NSLock()
                    var resultF: Function<T>?
                    var timedout = false
                    
                    let setTimedOut: (Bool) -> Void = {
                        mutex.lock()
                        defer { mutex.unlock() }
                        timedout = $0
                    }
                    
                    let setResult: (@escaping Function<T>) -> Void = {
                        mutex.lock()
                        defer { mutex.unlock() }
                        resultF = $0
                    }
                    
                    dq.async {
                        do {
                            let value = try f()
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
                        throw FPError.timeout(duration)
                    }
                }
            }
            
            return Composable(ff)
        }
    }
}
