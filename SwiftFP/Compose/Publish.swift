//
//  Publish.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Composable {
    
    /// Publish the result of a Supplier.
    ///
    /// - Parameter p: A callback function.
    /// - Returns: A Composable instance.
    public static func publish(_ p: @escaping (T) throws -> Void) -> Composable<T> {
        let ss: SupplierF<T> = {(s: @escaping Supplier<T>) throws -> Supplier<T> in
            return {
                let value = try s()
                try p(value)
                return value
            }
        }
        
        return Composable(ss)
    }
    
    /// publishError is similar to publish, but it only publishes if an error
    /// is encountered.
    ///
    /// - Parameter p: An error callback function.
    /// - Returns: A Composable instance.
    public static func publishError(_ p: @escaping (Error) throws -> Void) -> Composable<T> {
        let ss: SupplierF<T> = {(s: @escaping Supplier<T>) -> Supplier<T> in
            return {
                do {
                    return try s()
                } catch let e {
                    try p(e)
                    throw e
                }
            }
        }
        
        return Composable(ss)
    }
}
