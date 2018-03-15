//
//  Retry.swift
//  SwiftFP
//
//  Created by Hai Pham on 15/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Composable {
    
    /// Retry wraps an error-returning function with retry capabilities. It
    /// also keeps track of the current retry count, which may be useful if we
    /// want to define a custom retry delay function.
    ///
    /// - Parameter times: The number of times to retry.
    /// - Returns: A custom higher order function.
    public static func retryWithCount(_ times: Int) -> (@escaping (Int) throws -> T) -> Supplier<T> {
        return {(s: @escaping (Int) throws -> T) -> Supplier<T> in
            var retryF: ((Int) throws -> T)!
            
            retryF = {
                do {
                    return try s($0)
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
        let ss = {(s: @escaping Supplier<T>) -> Supplier<T> in
            let fCount: (Int) throws -> T = {_ in try s()}
            return retryWithCount(times)(fCount)
        }
        
        return Composable(ss)
    }
    
    /// Curry to provide retry and delay capabilities. Provide seconds for the
    /// time duration.
    ///
    /// - Parameter times: The number of times to retry.
    /// - Returns: A custom higher order function.
    public static func retryWithDelay(_ times: Int) -> (TimeInterval) -> Composable<T> {
        return {(d: TimeInterval) -> Composable<T> in
            let ss: SupplierF<T> = {(s: @escaping Supplier<T>) -> Supplier<T> in
                retryWithCount(times)({
                    if $0 > 0 { Thread.sleep(forTimeInterval: d) }
                    return try s()
                })
            }
            
            return Composable(ss)
        }
    }
}
