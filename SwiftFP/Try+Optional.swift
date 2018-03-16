//
//  Try+Optional.swift
//  SwiftFP
//
//  Created by Hai Pham on 7/8/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

extension Try: OptionalConvertibleType {
  public typealias Value = A

  public func asOptional() -> Optional<Value> {
    return value
  }
}

extension Try: OptionalType {
  public static func just(_ value: Value) -> Optional<Value> {
    return Optional<Value>.some(value)
  }

  public static func nothing() -> Optional<Value> {
    return Optional<Value>.none
  }
}

public extension Try {

  /// Produce a Try from an Optional, and throw an Error if the value is
  /// absent.
  ///
  /// - Parameters:
  ///   - optional: An Optional instance.
  ///   - error: The error to be thrown when there is no value.
  /// - Returns: A Try instance.
  public static func from<Val>(_ optional: Optional<Val>, _ error: Error) -> Try<Val> {
    switch optional {
    case .some(let value):
      return Try<Val>.success(value)

    case .none:
      return Try<Val>.failure(error)
    }
  }

  /// Produce a Try from an Optional, and throw an Error if the value is
  /// absent.
  ///
  /// - Parameters:
  ///   - optional: An Optional instance.
  ///   - error: The error to be thrown when there is no value.
  /// - Returns: A Try instance.
  public static func from<Val>(_ optional: Optional<Val>, _ error: String) -> Try<Val> {
    return Try.from(optional, FPError(error))
  }

  /// Produce a Try from an Optional, and throw a default Error if the value is
  /// absent.
  ///
  /// - Parameter optional: An Optional instance.
  /// - Returns: A Try instance.
  public static func from<Val>(_ optional: Optional<Val>) -> Try<Val> {
    return Try.from(optional, "\(Val.self) cannot be nil")
  }
}
