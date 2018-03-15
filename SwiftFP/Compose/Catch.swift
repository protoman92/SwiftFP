//
//  Catch.swift
//  SwiftFP
//
//  Created by Hai Pham on 15/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Composable {
    /// Catch the error and supply a different value.
    ///
    /// - Parameter c: A Error transform function.
    /// - Returns: A Composable instance.
    public static func `catch`(_ c: @escaping (Error) throws -> T) -> Composable<T> {
        let ff: FunctionF<T> = {(f: @escaping Function<T>) -> Function<T> in
            return {
                do {
                    return try f()
                } catch let e {
                    return try c(e)
                }
            }
        }
        
        return Composable(ff)
    }
}
