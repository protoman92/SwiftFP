//
//  Try.swift
//  SwiftUtilities
//
//  Created by Hai Pham on 7/8/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

/// Use this to wrap operations that can throw Error.
public protocol TryConvertibleType {
    associatedtype Val
    
    func asTry() -> Try<Val>
}

public protocol TryType: TryConvertibleType, EitherConvertibleType {
    
    /// Get the success value.
    var value: Val? { get }
    
    /// Get the failure error.
    var error: Error? { get }
}

public extension TryType {
    public func asEither() -> Either<Error,Val> {
        do {
            return Either.right(try getOrThrow())
        } catch let error {
            return Either.left(error)
        }
    }
    
    /// Check if the operation was successful.
    var isSuccess: Bool {
        return value != nil
    }
    
    /// Check if the operation failed.
    var isFailure: Bool {
        return !isSuccess
    }
    
    /// Return the current Try if the inner element passes a check, otherwise
    /// return a failure Try with the supplied error.
    ///
    /// - Parameters:
    ///   - selector: Selector function.
    ///   - error: An Error instance.
    /// - Returns: A Try instance.
    public func filter(_ selector: (Val) throws -> Bool, _ error: Error) -> Try<Val> {
        do {
            let value = try getOrThrow()
            return try selector(value) ? Try.success(value) : Try.failure(error)
        } catch let e {
            return Try.failure(e)
        }
    }
    
    /// Convenience method to filter out an inner element.
    ///
    /// - Parameters:
    ///   - selector: Selector function.
    ///   - error: A String value.
    /// - Returns: A Try instance.
    public func filter(_ selector: (Val) throws -> Bool, _ error: String) -> Try<Val> {
        return filter(selector, FPError.try(error))
    }
    
    /// Get success value or throw failure Error.
    ///
    /// - Returns: A Val instance.
    /// - Throws: Error if success value if absent.
    public func getOrThrow() throws -> Val {
        if let value = self.value {
            return value
        } else if let error = self.error {
            throw error
        } else {
            throw FPError.try("Invalid Try")
        }
    }
    
    /// Get success value if available, or return a backup success value.
    ///
    /// - Parameter backup: A Val instance.
    /// - Returns: A Val instance.
    public func getOrElse(_ backup: Val) -> Val {
        if let value = self.value {
            return value
        } else {
            return backup
        }
    }
    
    /// Get the current Try if it is successful, or return another Try if not.
    ///
    /// - Parameter backup: A TryConvertibleType instance.
    /// - Returns: A Try instance.
    public func getOrElse<TC>(_ backup: TC) -> Try<Val> where
        TC: TryConvertibleType, TC.Val == Val
    {
        return isSuccess ? self.asTry() : backup.asTry()
    }
    
    /// Zip with another Try instance to produce a Try of another type.
    ///
    /// - Parameters:
    ///   - try2: A TryConvertibleType instance.
    ///   - f: Transform function.
    /// - Returns: A Try instance.
    public func zipWith<V2,V3,T>(_ try2: T, _ f: (Val, V2) throws -> V3)
        -> Try<V3> where T: TryConvertibleType, T.Val == V2
    {
        return flatMap({v1 in try2.asTry().map({try f(v1, $0)})})
    }
    
    /// Zip two Try instances to produce a Try of another type.
    ///
    /// - Parameters:
    ///   - try1: A TryConvertibleType instance.
    ///   - try2: A TryConvertibleType instance.
    ///   - f: Transform function.
    /// - Returns: A Try instance.
    public static func zip<V1,V2,V3,T1,T2>(_ try1: T1, _ try2: T2,
                                           _ f: (V1, V2) throws -> V3)
        -> Try<V3> where
        T1: TryConvertibleType, T1.Val == V1,
        T2: TryConvertibleType, T2.Val == V2
    {
        return try1.asTry().zipWith(try2, f)
    }
    
    /// Zip a Sequence of TryConvertibleType with a result selector function.
    ///
    /// - Parameters:
    ///   - tries: A Sequence of TryConvertibleType.
    ///   - resultSelector: Selector function.
    /// - Returns: A Try instance.
    public static func zip<V1,V2,TC,S>(_ tries: S, _ resultSelector: ([V1]) throws -> V2)
        -> Try<V2> where
        TC: TryConvertibleType, TC.Val == V1,
        S: Sequence, S.Element == TC
    {
        do {
            let values = try tries.map({try $0.asTry().getOrThrow()})
            return try Try<V2>.success(resultSelector(values))
        } catch let e {
            return Try<V2>.failure(e)
        }
    }
    
    /// Zip a Sequence of TryConvertibleType with a result selector function.
    ///
    /// - Parameters:
    ///   - resultSelector: Selector function.
    ///   - tries: Varargs of TryConvertibleType.
    /// - Returns: A Try instance.
    public static func zip<V1,V2,TC>(_ resultSelector: ([V1]) throws -> V2,
                                     _ tries: TC...) -> Try<V2> where
        TC: TryConvertibleType, TC.Val == V1
    {
        return zip(tries, resultSelector)
    }
}

public extension TryType {
    
    /// Functor.
    ///
    /// - Parameter f: Transform function.
    /// - Returns: A Try instance.
    public func map<A1>(_ f: (Val) throws -> A1) -> Try<A1> {
        return Try({try f(self.getOrThrow())})
    }
    
    /// Applicative.
    ///
    /// - Parameter t: A TryConvertibleType instance.
    /// - Returns: A Try instance.
    public func apply<T,A1>(_ t: T) -> Try<A1>
        where T: TryConvertibleType, T.Val == (Val) throws -> A1
    {
        return flatMap({a in t.asTry().map({try $0(a)})})
    }
    
    /// Monad.
    ///
    /// - Parameter f: Transform function.
    /// - Returns: A Try instance.
    public func flatMap<T,Val2>(_ f: (Val) throws -> T) -> Try<Val2>
        where T: TryConvertibleType, T.Val == Val2    {
        do {
            return try f(try getOrThrow()).asTry()
        } catch let error {
            return Try.failure(error)
        }
    }
}

public enum Try<A> {
    case success(A)
    case failure(Error)
    
    public init(_ f: () throws -> A) {
        do {
            self = .success(try f())
        } catch let error {
            self = .failure(error)
        }
    }
    
    public init(_ value: A) {
        self = .success(value)
    }
    
    public init(_ error: Error) {
        self = .failure(error)
    }
}

extension Try: TryType {
    public func asTry() -> Try<A> {
        return self
    }
    
    public var value: A? {
        switch self {
        case .success(let value):
            return value
            
        default:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .failure(let error):
            return error
            
        default:
            return nil
        }
    }
}
