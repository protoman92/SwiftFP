//
//  Error.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Composable {
    
    /// Retry wraps an error-returning function with retry capabilities. It
    /// also keeps track of the current retry count, which may be useful if we
    /// want to define a custom retry delay function.
    ///
    /// - Parameter times: The number of times to retry.
    /// - Returns: A custom higher order function.
    public static func retryWithCount(_ times: Int) -> (@escaping (Int) throws -> T) -> Function<T> {
        return {(f: @escaping (Int) throws -> T) -> Function<T> in
            var retryF: ((Int) throws -> T)!
            
            retryF = {
                do {
                    return try f($0)
                } catch let e {
                    if $0 < times {
                        return try retryF($0 + 1)
                    } else {
                        throw e
                    }
                }
            }
            
            return {try retryF(0)}
        }
    }
    
    /// Retry has the same semantics as retryWithCount, but ignores the current
    /// retry count.
    ///
    /// - Parameter times: The number of times to retry.
    /// - Returns: A Composable instance.
    public static func retry(_ times: Int) -> Composable<T> {
        let ff = {(f: @escaping Function<T>) -> Function<T> in
            let fCount: (Int) throws -> T = {_ in try f()}
            return retryWithCount(times)(fCount)
        }
        
        return Composable(ff)
    }
    
    /// Curry to provide retry and delay capabilities. Provide seconds for the
    /// time duration.
    ///
    /// - Parameter times: The number of times to retry.
    /// - Returns: A custom higher order function.
    public static func retryWithDelay(_ times: Int) -> (TimeInterval) -> Composable<T> {
        return {(d: TimeInterval) -> Composable<T> in
            let ff: FunctionF<T> = {(f: @escaping Function<T>) -> Function<T> in
                retryWithCount(times)({
                    if $0 > 0 {
                        Thread.sleep(forTimeInterval: d)
                    }
                    
                    return try f()
                })
            }
            
            return Composable(ff)
        }
    }
    
    /// publishError is similar to publish, but it only publishes if an error
    /// is encountered.
    ///
    /// - Parameter p: An error callback function.
    /// - Returns: A Composable instance.
    public static func publishError(_ p: @escaping (Error) throws -> Void) -> Composable<T> {
        let ff: FunctionF<T> = {(f: @escaping Function<T>) -> Function<T> in
            return {
                do {
                    return try f()
                } catch let e {
                    try p(e)
                    throw e
                }
            }
        }
        
        return Composable(ff)
    }
}
