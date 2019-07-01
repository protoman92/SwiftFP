//
//  Optional.swift
//  SwiftFP
//
//  Created by Hai Pham on 24/9/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

/// Classes that implement this protocol should be convertible to an Optional.
public protocol OptionalConvertibleType {
  associatedtype Value

  func asOptional() -> Optional<Value>
}

/// Classes that implement this protocol must be expressible as an Optional.
public protocol OptionalType: OptionalConvertibleType {
  static func just(_ value: Value) -> Optional<Value>

  static func nothing() -> Optional<Value>

  var value: Value? { get }

  /// Convenience method to cast the inner value to a different type.
  ///
  /// - Parameter cls: Class type.
  /// - Returns: An Optional instance.
  func cast<T>(_ cls: T.Type) -> Optional<T>
}

public extension OptionalType {
  var isSome: Bool {
    return value != nil
  }

  var isNothing: Bool {
    return !isSome
  }

  /// Return the current Optional, or a backup Optional is the former is empty.
  ///
  /// - Parameter backup: An Optional instance.
  /// - Returns: An Optional instance.
  func getOrElse(_ backup: Optional<Value>) -> Optional<Value> {
    return isSome ? self.asOptional() : backup
  }

  /// Return the current Optional, or a backup Optional is the former is empty.
  ///
  /// - Parameter backup: An OptionalConvertibleType instance.
  /// - Returns: An Optional instance.
  func someOrElse<OC>(_ backup: OC) -> Optional<Value> where
    OC: OptionalConvertibleType, OC.Value == Value
  {
    return getOrElse(backup.asOptional())
  }
}

extension Optional: OptionalType {
  public typealias Value = Wrapped

  public static func just(_ value: Value) -> Optional<Value> {
    return .some(value)
  }

  public static func nothing() -> Optional<Value> {
    return .none
  }

  public func asOptional() -> Optional<Value> {
    return self
  }

  public var value: Value? {
    switch self {
    case .some(let value): return value
    default: return nil
    }
  }

  public func cast<T>(_ cls: T.Type) -> Optional<T> {
    return flatMap({$0 as? T})
  }

  /// Get the wrapped value, or a default value if it is not available.
  ///
  /// - Parameter value: A Value instance.
  /// - Returns: A Value instance.
  public func getOrElse(_ value: Value) -> Value {
    switch self {
    case .some(let a): return a
    case .none: return value
    }
  }

  /// Get the Value instance or throw an Error.
  ///
  /// - Parameter error: An Error instance.
  /// - Returns: A Value instance.
  /// - Throws: Error if the value is not available.
  public func getOrThrow(_ error: Error) throws -> Value {
    switch self {
    case .some(let a): return a
    case .none: throw error
    }
  }

  /// Get the Value instance or throw an Error.
  ///
  /// - Parameter error: A String value.
  /// - Returns: A Value instance.
  /// - Throws: Error if the value is not available.
  public func getOrThrow(_ error: String) throws -> Value {
    return try getOrThrow(FPError(error))
  }

  /// Filter the inner value using a selector and return nothing if it does
  /// not pass the predicate.
  ///
  /// - Parameter selector: Selector function.
  /// - Returns: An Optional instance.
  public func filter(_ selector: (Value) throws -> Bool) -> Optional<Value> {
    return asTry().filter(selector, "").asOptional()
  }
}
