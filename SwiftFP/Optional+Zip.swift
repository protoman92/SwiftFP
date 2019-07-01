//
//  Optional+Zip.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Optional {

  /// Zip a Sequence of OptionalConvertibleType with a resultSelector.
  ///
  /// - Parameters:
  ///   - optionals: A Sequence of OptionalConvertibleType.
  ///   - resultSelector: Selector function.
  /// - Returns: An Optional instance.
  static func zip<OC, W2, S>(_ optionals: S, _ resultSelector: ([OC.Value]) throws -> W2)
    -> Optional<W2> where
    OC: OptionalConvertibleType,
    S: Sequence, S.Element == OC
  {
    let tries = optionals.map({$0.asOptional().asTry()})
    return Try<W2>.zip(tries, resultSelector).value
  }

  /// Zip a Sequence of OptionalConvertibleType with a resultSelector.
  ///
  /// - Parameters:
  ///   - resultSelector: Selector function.
  ///   - optionals: Varargs of OptionalConvertibleType.
  /// - Returns: An Optional instance.
  static func zip<OC, W2>(_ resultSelector: ([OC.Value]) throws -> W2,
                          _ optionals: OC...) -> Optional<W2> where
    OC: OptionalConvertibleType
  {
    return zip(optionals, resultSelector)
  }

  /// Zip with another Optional with a selector function.
  ///
  /// - Parameters:
  ///   - optional: An OptionalConvertibleType instance.
  ///   - resultSelector: Selector function.
  /// - Returns: An Optional instance.
  func zipWith<OC, W2>(_ optional: OC, _ resultSelector: (Value, OC.Value) throws -> W2)
    -> Optional<W2> where OC: OptionalConvertibleType
  {
    return asTry().zipWith(optional.asOptional(), resultSelector).value
  }
}
