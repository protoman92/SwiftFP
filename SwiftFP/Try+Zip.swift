//
//  Try+Zip.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

extension Try {

  /// Zip two Try instances to produce a Try of another type.
  ///
  /// - Parameters:
  ///   - try1: A TryConvertibleType instance.
  ///   - try2: A TryConvertibleType instance.
  ///   - f: Transform function.
  /// - Returns: A Try instance.
  public static func zip<V1, V2, V3, T1, T2>(_ try1: T1, _ try2: T2,
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
  public static func zip<V1, V2, TC, S>(_ tries: S,
                                        _ resultSelector: ([V1]) throws -> V2)
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
  public static func zip<V1, V2, TC>(_ resultSelector: ([V1]) throws -> V2,
                                     _ tries: TC...) -> Try<V2> where
    TC: TryConvertibleType, TC.Val == V1
  {
    return zip(tries, resultSelector)
  }

  /// Zip with another Try instance to produce a Try of another type.
  ///
  /// - Parameters:
  ///   - try2: A TryConvertibleType instance.
  ///   - f: Transform function.
  /// - Returns: A Try instance.
  public func zipWith<V2, V3, T>(_ try2: T, _ f: (Val, V2) throws -> V3)
    -> Try<V3> where T: TryConvertibleType, T.Val == V2
  {
    return flatMap({v1 in try2.asTry().map({try f(v1, $0)})})
  }
}
