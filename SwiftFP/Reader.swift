//
//  Reader.swift
//  SwiftUtilities
//
//  Created by Hai Pham on 7/8/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

/// Use this to implement Dependency Injection.
public protocol ReaderConvertibleType {
    associatedtype Env
    associatedtype Val
    
    func asReader() -> Reader<Env, Val>
}

/// A Reader that has the same signature for A and B.
public typealias EQReader<A> = Reader<A, A>

public protocol ReaderType: ReaderConvertibleType {
    var f: (Env) throws -> Val { get }
}

public extension ReaderType {
    
    public func run(_ a: Env) throws -> Val {
        return try f(a)
    }

    /// Call f and wrap the result in a Try.
    ///
    /// - Parameter a: Env instance.
    /// - Returns: A Try instance.
    public func tryRun(_ env: Env) -> Try<Val> {
        return Try({try self.run(env)})
    }
    
    /// Modify the environment with which to execute the function.
    ///
    /// - Parameter g: Tranform function.
    /// - Returns: A Reader instance.
    public func modify<Env1>(_ g: @escaping (Env1) throws -> Env) -> Reader<Env1, Val> {
        return Reader({try self.run(g($0))})
    }
    
    /// Functor.
    ///
    /// - Parameter g: Transform function.
    /// - Returns: A Reader instance.
    public func map<Val1>(_ g: @escaping (Val) throws -> Val1) -> Reader<Env, Val1> {
        return Reader<Env, Val1>({try g(self.run($0))})
    }
    
    /// Applicative.
    ///
    /// - Parameter r: ReaderConvertibleType instance.
    /// - Returns: A Reader instance.
    public func apply<R, Val1>(_ r: R) -> Reader<Env, Val1>
        where R: ReaderConvertibleType, R.Env == Env, R.Val == (Val) throws -> Val1
    {
        return flatMap({val in r.asReader().map({try $0(val)})})
    }
    
    /// Monad.
    ///
    /// - Parameter g: Transform function.
    /// - Returns: A Reader instance.
    public func flatMap<R, Val1>(_ g: @escaping (Val) throws -> R) -> Reader<Env, Val1>
        where R: ReaderConvertibleType, R.Env == Env, R.Val == Val1
    {
        return Reader<Env, Val1>({try g(self.f($0)).asReader().run($0)})
    }
    
    /// Zip with another ReaderConvertibleType.
    ///
    /// - Parameters:
    ///   - reader: A ReaderConvertibleType instance.
    ///   - g: Transform function.
    /// - Returns: A Reader instance.
    public func zip<R, Val1, U>(with reader: R, _ g: @escaping (Val, Val1) throws -> U)
        -> Reader<Env, U> where R: ReaderConvertibleType, R.Env == Env, R.Val == Val1
    {
        return flatMap({val in reader.asReader().map({try g(val, $0)})})
    }
    
    /// Zip with another ReaderConvertibleType with a different A.
    ///
    /// - Parameters:
    ///   - reader: A ReaderConvertibleType instance.
    ///   - g: Transform function.
    /// - Returns: A Reader instance.
    public func zip<R, Env1, Val1, U>(with reader: R, _ g: @escaping (Val, Val1) throws -> U)
        -> Reader<(Env,Env1),U> where R: ReaderConvertibleType, R.Env == Env1, R.Val == Val1
    {
        return Reader({try g(self.run($0.0), reader.asReader().run($0.1))})
    }
}

public struct Reader<Env, Val> {
    public let f: (Env) throws -> Val
    
    public init(_ f: @escaping (Env) throws -> Val) {
        self.f = f
    }
}

extension Reader: ReaderType {
    public func asReader() -> Reader<Env, Val> {
        return self
    }
}

public extension Reader {
    
    /// Get a Reader whose f simply returns whatever is passed in.
    ///
    /// - Returns: A Reader instance.
    public static func eq<Env>() -> EQReader<Env> {
        return Reader<Env, Env>({$0})
    }
    
    /// Get a Reader whose f simply returns a value.
    ///
    /// - Parameter value: Base.Val instance.
    /// - Returns: A Reader instance.
    public static func just<Env, Val>(_ value: Val) -> Reader<Env, Val> {
        return Reader<Env, Val>({_ in value})
    }
    
    /// Convenient method to zip two ReaderConvertibleType.
    ///
    /// - Parameters:
    ///   - r1: R1 instance.
    ///   - r2: R2 instance.
    ///   - g: Transform function.
    /// - Returns: A Reader instance.
    public static func zip<R1, R2, Env, Val, Val1, U>(
        _ r1: R1, _ r2: R2,
        _ g: @escaping (Val, Val1) throws -> U)
        -> Reader<Env, U> where
        R1: ReaderConvertibleType,
        R2: ReaderConvertibleType,
        R1.Env == Env, R1.Val == Val,
        R2.Env == Env, R2.Val == Val1
    {
        return r1.asReader().zip(with: r2, g)
    }
    
    /// Convenient method to zip two ReaderConvertibleType.
    ///
    /// - Parameters:
    ///   - r1: R1 instance.
    ///   - r2: R2 instance.
    ///   - g: Transform function.
    /// - Returns: A Reader instance.
    public static func zip<R1, R2, Env, Val, Env1, Val1, U>(
        _ r1: R1, _ r2: R2,
        _ g: @escaping (Val, Val1) throws -> U)
        -> Reader<(Env, Env1), U> where
        R1: ReaderConvertibleType,
        R2: ReaderConvertibleType,
        R1.Env == Env, R1.Val == Val,
        R2.Env == Env1, R2.Val == Val1
    {
        return r1.asReader().zip(with: r2, g)
    }
    
    /// Zip a Sequence of ReaderConvertibleType using a function.
    ///
    /// - Parameters:
    ///   - readers: A Sequence of ReaderConvertibleType.
    ///   - g: Transform function.
    /// - Returns: A Reader instance.
    public static func zip<S, Env, Val, Val1>(_ readers: S,
                                              _ g: @escaping ([Val]) throws -> Val1)
        -> Reader<Env, Val1> where
        S: Sequence,
        S.Iterator.Element: ReaderConvertibleType,
        S.Iterator.Element.Env == Env,
        S.Iterator.Element.Val == Val
    {
        return Reader<Env, Val1>({(env: Env) throws -> Val1 in
            try g(readers.map({$0.asReader()}).map({try $0.run(env)}))
        })
    }
    
    /// Same as above, but uses varargs of ReaderConvertibleType.
    ///
    /// - Parameters:
    ///   - g: Transform function.
    ///   - readers: Varargs of ReaderConvertibleType.
    /// - Returns: A Reader instance.
    public static func zip<R, Env, Val, Val1>(_ g: @escaping ([Val]) throws -> Val1,
                                              _ readers: R...)
        -> Reader<Env, Val1> where
        R: ReaderConvertibleType,
        R.Env == Env, R.Val == Val
    {
        return Reader.zip(readers.map({$0}), g)
    }
    
    /// Zip a Sequence of ReaderConvertibleType using a function that is applied
    /// only on those that do not produce errors while running on some Env
    /// instance.
    ///
    /// - Parameters:
    ///   - readers: A Sequence of ReaderConvertibleType.
    ///   - g: Transform function.
    /// - Returns: A Reader instance.
    public static func zip<S, Env, Val, Val1>(ignoringErrors readers: S,
                                              _ g: @escaping ([Val]) throws -> Val1)
        -> Reader<Env, Val1> where
        S: Sequence,
        S.Iterator.Element: ReaderConvertibleType,
        S.Iterator.Element.Env == Env,
        S.Iterator.Element.Val == Val
    {
        return Reader<Env, Val1>({(env: Env) throws -> Val1 in
            try g(readers
                .map({$0.asReader()})
                .map({$0.tryRun(env)})
                .flatMap({$0.value}))
        })
    }
    
    /// Same as above, but uses varargs of ReaderConvertibleType.
    ///
    /// - Parameters:
    ///   - g: Transform function.
    ///   - readers: Varargs of ReaderConvertibleType.
    /// - Returns: A Reader instance.
    public static func zip<R, Env, Val, Val1>(_ g: @escaping ([Val]) throws -> Val1,
                                              ignoringErrors readers: R...)
        -> Reader<Env, Val1> where
        R: ReaderConvertibleType,
        R.Env == Env, R.Val == Val
    {
        return Reader.zip(ignoringErrors: readers.map({$0}), g)
    }
}

