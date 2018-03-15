//
//  Optionals.swift
//  SwiftUtilities
//
//  Created by Hai Pham on 31/7/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

extension Optional: TryConvertibleType {
    public typealias Val = Wrapped
    
    /// Convert this Optional into a Try.
    ///
    /// - Returns: A Try instance.
    public func asTry() -> Try<Val> {
        return Try<Val>.from(optional: self)
    }
    
    /// Convert this Optional into a Try.
    ///
    /// - Parameter error: An Error instance.
    /// - Returns: A Try instance.
    public func asTry(error: Error) -> Try<Val> {
        return Try<Val>.from(optional: self, error: error)
    }
    
    /// Convert this Optional into a Try.
    ///
    /// - Parameter error: A String value.
    /// - Returns: A Try instance.
    public func asTry(error: String) -> Try<Val> {
        return asTry(error: FPError(error))
    }
}
