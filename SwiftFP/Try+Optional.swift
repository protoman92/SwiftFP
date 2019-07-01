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

public extension Try {

  /// Produce a Try from an Optional, and throw an Error if the value is
  /// absent.
  ///
  /// - Parameters:
  ///   - optional: An Optional instance.
  ///   - error: The error to be thrown when there is no value.
  /// - Returns: A Try instance.
  static func from(_ optional: Optional<Value>, _ error: Error) -> Try<Value> {
    switch optional {
    case .some(let value):
      return Try<Value>.success(value)

    case .none:
      return Try<Value>.failure(error)
    }
  }

  /// Produce a Try from an Optional, and throw an Error if the value is
  /// absent.
  ///
  /// - Parameters:
  ///   - optional: An Optional instance.
  ///   - error: The error to be thrown when there is no value.
  /// - Returns: A Try instance.
  static func from(_ optional: Optional<Value>, _ error: String) -> Try<Value> {
    return Try.from(optional, FPError(error))
  }

  /// Produce a Try from an Optional, and throw a default Error if the value is
  /// absent.
  ///
  /// - Parameter optional: An Optional instance.
  /// - Returns: A Try instance.
  static func from(_ optional: Optional<Value>) -> Try<Value> {
    return Try.from(optional, "\(Value.self) cannot be nil")
  }
}
