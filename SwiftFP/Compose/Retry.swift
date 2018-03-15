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
        assert(times >= 0, "Expected retry to be more than 0, but got \(times)")
        
        return {(s: @escaping (Int) throws -> T) -> Supplier<T> in
            return {
                var current = 0
                
                while true {
                    do {
                        return try s(current)
                    } catch let e {
                        if current == times {
                            throw e
                        }
                    }
                    
                    current += 1
                }
            }
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
