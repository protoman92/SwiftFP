//
//  Composable.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Supplier represents a function that returns some data.
public typealias Supplier<T> = () throws -> T

/// SupplierF represents a function that maps a Supplier to another Supplier.
public typealias SupplierF<T> = (@escaping Supplier<T>) throws -> Supplier<T>

/// Composable represents a function wrapper that can compose with other
/// Composables to enhance the wrapped function.
public struct Composable<T> {
    private let sf: SupplierF<T>
    
    public init(_ sf: @escaping SupplierF<T>) {
        self.sf = sf
    }
    
    /// Invoke the inner SupplierF.
    ///
    /// - Parameter s: A Supplier instance.
    /// - Returns: A Supplier instance.
    /// - Throws: If the operation fails.
    public func invoke(_ s: @escaping Supplier<T>) throws -> Supplier<T> {
        return try sf(s)
    }
    
    /// Compose with another SupplierF to enhance functionalities.
    ///
    /// - Parameter sf: A SupplierF instance.
    /// - Returns: A Composable instance.
    public func compose(_ sf: @escaping SupplierF<T>) -> Composable<T> {
        let newFF: SupplierF<T> = {(s: @escaping Supplier<T>) -> Supplier<T> in
            return try self.invoke(sf(s))
        }
        
        return Composable(newFF)
    }

    /// Compose with another Composable to enhance functionalities.
    ///
    /// - Parameter cp: A Composable instance.
    /// - Returns: A Composable instance.
    public func compose(_ cp: Composable<T>) -> Composable<T> {
        return compose(cp.sf)
    }
}
