//
//  Publish.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Composable {
    
    /// Publish the result of a function.
    ///
    /// - Parameter p: A callback function.
    /// - Returns: A Composable instance.
    public static func publish(_ p: @escaping (T) throws -> Void) -> Composable<T> {
        let ff: FunctionF<T> = {(f: @escaping Function<T>) throws -> Function<T> in
            return {
                let value = try f()
                try p(value)
                return value
            }
        }
        
        return Composable(ff)
    }
}
