//
//  State.swift
//  SwiftUtilities
//
//  Created by Hai Pham on 7/10/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

/// Use this to store, modify and pass state information.
public typealias StatePair<S,A> = (state: S, value: A)

public protocol StateConvertibleType {
    associatedtype Val
    associatedtype Stat
    
    func asState() -> State<Stat,Val>
}

public protocol StateType: StateConvertibleType {
    var f: (Stat) throws -> StatePair<Stat,Val> { get }
}

public extension StateType {
    public func run(_ s: Stat) throws -> StatePair<Stat,Val> {
        return try f(s)
    }
    
    public func tryRun(_ s: Stat) -> Try<StatePair<Stat,Val>> {
        return Try({try self.run(s)})
    }
    
    public func run1(_ s: Stat) throws -> Stat {
        return try run(s).state
    }
    
    public func tryRun1(_ s: Stat) -> Try<Stat> {
        return Try({try self.run1(s)})
    }
    
    public func run2(_ s: Stat) throws -> Val {
        return try run(s).value
    }
    
    public func tryRun2(_ s: Stat) -> Try<Val> {
        return Try({try self.run2(s)})
    }
    
    /// Change state signature with a transform function.
    ///
    /// - Parameter g: Transform function.
    /// - Returns: A State instance.
    public func modify<Stat1>(_ g: @escaping (Stat1) throws -> Stat) -> State<Stat1,Val> {
        return State({try StatePair($0, self.run2(g($0)))})
    }
    
    /// Modify the state with the same type.
    ///
    /// - Parameter g: Transform function.
    /// - Returns: A State instance.
    public func modify(_ g: @escaping (Stat) throws -> Stat) -> State<Stat,Val> {
        return State({
            let (s, v) = try self.run($0)
            return try StatePair(g(s), v)
        })
    }
    
    /// Functor.
    ///
    /// - Parameter g: Transform function.
    /// - Returns: A State instance.
    public func map<Val1>(_ g: @escaping (Val) throws -> Val1) -> State<Stat,Val1> {
        return State({
            let (s, v) = try self.run($0)
            return try StatePair(s, g(v))
        })
    }
    
    /// Applicative.
    ///
    /// - Parameter st: A StateConvertibleType instance.
    /// - Returns: A State instance.
    public func apply<ST,Val1>(_ st: ST) -> State<Stat,Val1>
        where ST: StateConvertibleType, ST.Stat == Stat, ST.Val == (Val) throws -> Val1
    {
        return flatMap({val in st.asState().map({try $0(val)})})
    }
    
    /// Monad.
    ///
    /// - Parameter g: Transform function.
    /// - Returns: A State instance.
    public func flatMap<ST,Val1>(_ g: @escaping (Val) throws -> ST) -> State<Stat,Val1>
        where ST: StateConvertibleType, ST.Stat == Stat, ST.Val == Val1
    {
        return State({
            let (s, v) = try self.run($0)
            return try g(v).asState().run(s)
        })
    }
}

public struct State<Stat,Val> {
    public let f: (Stat) throws -> StatePair<Stat,Val>
    
    public init(_ f: @escaping (Stat) throws -> (Stat, Val)) {
        self.f = f
    }
}

extension State: StateType {
    public func asState() -> State<Stat,Val> {
        return self
    }
}
