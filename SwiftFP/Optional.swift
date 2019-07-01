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
}

public extension OptionalType {
  var isSome: Bool {
    return value != nil
  }

  var isNothing: Bool {
    return !isSome
  }
  
  /// Convenience method to cast the inner value to a different type.
  ///
  /// - Parameter cls: Class type.
  /// - Returns: An Optional instance.
  func cast<T>(_ cls: T.Type) -> Optional<T> {
    return value.flatMap({$0 as? T})
  }
  
  /// Filter the inner value using a selector and return nothing if it does
  /// not pass the predicate.
  ///
  /// - Parameter selector: Selector function.
  /// - Returns: An Optional instance.
  func filter(_ selector: (Value) throws -> Bool) -> Optional<Value> {
    return value.flatMap({try? selector($0)}) ?? false ? value : nil
  }
  
  /// Get the wrapped value, or a default value if it is not available.
  ///
  /// - Parameter value: A Value instance.
  /// - Returns: A Value instance.
  func getOrElse(_ value: Value) -> Value {
    return self.value ?? value
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
  
  /// Get the Value instance or throw an Error.
  ///
  /// - Parameter error: An Error instance.
  /// - Returns: A Value instance.
  /// - Throws: Error if the value is not available.
  func getOrThrow(_ error: Error) throws -> Value {
    guard let value = self.value else { throw error }
    return value
  }
  
  /// Get the Value instance or throw an Error.
  ///
  /// - Parameter error: A String value.
  /// - Returns: A Value instance.
  /// - Throws: Error if the value is not available.
  func getOrThrow(_ error: String) throws -> Value {
    return try getOrThrow(FPError(error))
  }
  
  /// Catch a Nothing Optional and return a backup value.
  ///
  /// - Parameter fn: Function that produces the backup value.
  /// - Returns: An Optional instance.
  func catchNothing(_ fn: () throws -> Value) -> Optional<Value> {
    return value ?? (try? fn())
  }
}

// MARK: - OptionalType
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
}

// MARK: - TryConvertibleType
extension Optional: TryConvertibleType {
  
  /// Convert this Optional into a Try.
  ///
  /// - Returns: A Try instance.
  public func asTry() -> Try<Value> {
    return Try<Value>.from(self)
  }
  
  /// Convert this Optional into a Try.
  ///
  /// - Parameter error: An Error instance.
  /// - Returns: A Try instance.
  public func asTry(_ error: Error) -> Try<Value> {
    return Try<Value>.from(self, error)
  }
  
  /// Convert this Optional into a Try.
  ///
  /// - Parameter error: A String value.
  /// - Returns: A Try instance.
  public func asTry(_ error: String) -> Try<Value> {
    return asTry(FPError(error))
  }
}

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

