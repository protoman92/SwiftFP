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
    
    /// Invoke the inner Supplier asynchronously with a provided DispatchQueue
    /// and callbacks.
    ///
    /// - Parameter onNext: A T callback function.
    /// - Throws: If the operation fails.
    public func invokeAsync(_ onNext: @escaping (T) throws -> Void)
        -> (@escaping (Error) -> Void)
        -> (@escaping () throws -> Void)
        -> (DispatchQueue)
        -> (@escaping Supplier<T>)
        -> Void
    {
        return {(onError: @escaping (Error) -> Void) in
            return {(onComplete: @escaping () throws -> Void) in
                return {(dq: DispatchQueue) in
                    return {(s: @escaping Supplier<T>) in
                        dq.async {
                            do {
                                let value = try self.invoke(s)()
                                try onNext(value)
                                try onComplete()
                            } catch let e {
                                onError(e)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Compose with another SupplierF to enhance functionalities.
    ///
    /// - Parameter sf: A SupplierF instance.
    /// - Returns: A Composable instance.
    public func compose(_ sf: @escaping SupplierF<T>) -> Composable<T> {
        let newSf: SupplierF<T> = {(s: @escaping Supplier<T>) -> Supplier<T> in
            return try self.invoke(sf(s))
        }
        
        return Composable(newSf)
    }

    /// Compose with another Composable to enhance functionalities.
    ///
    /// - Parameter cp: A Composable instance.
    /// - Returns: A Composable instance.
    public func compose(_ cp: Composable<T>) -> Composable<T> {
        return compose(cp.sf)
    }
}
