//
//  Composable.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Function represents a function that returns some data.
public typealias Function<T> = () throws -> T

/// FunctionF represents a function that maps a Function to another Function.
public typealias FunctionF<T> = (@escaping Function<T>) throws -> Function<T>

/// Composable represents a function wrapper that can compose with other
/// Composables to enhance the wrapped function.
public struct Composable<T> {
    private let ff: FunctionF<T>
    
    public init(_ ff: @escaping FunctionF<T>) {
        self.ff = ff
    }
    
    /// Invoke the inner FunctionF.
    ///
    /// - Parameter f: A Function instance.
    /// - Returns: A Function instance.
    /// - Throws: If the operation fails.
    public func invoke(_ f: @escaping Function<T>) throws -> Function<T> {
        return try ff(f)
    }
    
    /// Compose with another FunctionF to enhance functionalities.
    ///
    /// - Parameter ff: A FunctionF instance.
    /// - Returns: A Composable instance.
    public func compose(_ ff: @escaping FunctionF<T>) -> Composable<T> {
        let newFF: FunctionF<T> = {(f: @escaping Function<T>) -> Function<T> in
            return try self.invoke(ff(f))
        }
        
        return Composable(newFF)
    }

    /// Compose with another Composable to enhance functionalities.
    ///
    /// - Parameter cp: A Composable instance.
    /// - Returns: A Composable instance.
    public func compose(_ cp: Composable<T>) -> Composable<T> {
        return compose(cp.ff)
    }
}
