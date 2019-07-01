//
//  Try+Zip.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Try {

  /// Zip two Try instances to produce a Try of another type.
  ///
  /// - Parameters:
  ///   - try1: A TryConvertibleType instance.
  ///   - try2: A TryConvertibleType instance.
  ///   - f: Transform function.
  /// - Returns: A Try instance.
  static func zip<T1, T2, V3>(_ try1: T1, _ try2: T2, _ f: (T1.Val, T2.Val) throws -> V3)
    -> Try<V3> where
    T1: TryConvertibleType,
    T2: TryConvertibleType
  {
    return try1.asTry().zipWith(try2, f)
  }

  /// Zip a Sequence of TryConvertibleType with a result selector function.
  ///
  /// - Parameters:
  ///   - tries: A Sequence of TryConvertibleType.
  ///   - resultSelector: Selector function.
  /// - Returns: A Try instance.
  static func zip<TC, V2, S>(_ tries: S, _ resultSelector: ([TC.Val]) throws -> V2)
    -> Try<V2> where
    TC: TryConvertibleType,
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
  static func zip<TC, V2>(_ resultSelector: ([TC.Val]) throws -> V2,
                          _ tries: TC...) -> Try<V2> where
    TC: TryConvertibleType
  {
    return zip(tries, resultSelector)
  }

  /// Zip with another Try instance to produce a Try of another type.
  ///
  /// - Parameters:
  ///   - try2: A TryConvertibleType instance.
  ///   - f: Transform function.
  /// - Returns: A Try instance.
  public func zipWith<TC, V2>(_ try2: TC, _ f: (Val, TC.Val) throws -> V2)
    -> Try<V2> where TC: TryConvertibleType
  {
    return flatMap({v1 in try2.asTry().map({try f(v1, $0)})})
  }
}
