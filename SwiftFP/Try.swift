//
//  Try.swift
//  SwiftFP
//
//  Created by Hai Pham on 7/8/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

/// Use this to wrap operations that can throw Error.
public protocol TryConvertibleType {
  associatedtype Value

  func asTry() -> Try<Value>
}

public protocol TryType: TryConvertibleType, EitherConvertibleType {

  /// Get the success value.
  var value: Value? { get }

  /// Get the failure error.
  var error: Error? { get }
}

public extension TryType {
  func asEither() -> Either<Error, Value> {
    do {
      return Either.right(try getOrThrow())
    } catch {
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
  
  /// Catch an Error Try and return a fallback value.
  ///
  /// - Parameter fn: Function that returns the fallback value.
  /// - Returns: A Try instance.
  func catchError(_ fn: (Error) throws -> Value) -> Try<Value> {
    do {
      return (try error.map({try fn($0)}) ?? value).asTry()
    } catch {
      return .failure(error)
    }
  }

  /// Get success value or throw failure Error.
  ///
  /// - Returns: A Value instance.
  /// - Throws: Error if success value if absent.
  func getOrThrow() throws -> Value {
    if let value = self.value {
      return value
    } else if let error = self.error {
      throw error
    } else {
      throw FPError("Invalid Try")
    }
  }

  /// Get success value if available, or return a backup success value.
  ///
  /// - Parameter backup: A Value instance.
  /// - Returns: A Value instance.
  func getOrElse(_ backup: Value) -> Value {
    return value ?? backup
  }

  /// Get the current Try if it is successful, or return another Try if not.
  ///
  /// - Parameter backup: A TryConvertibleType instance.
  /// - Returns: A Try instance.
  func successOrElse<TC>(_ backup: TC) -> Try<Value> where
    TC: TryConvertibleType, TC.Value == Value
  {
    return isSuccess ? self.asTry() : backup.asTry()
  }

  /// Return the current Try if the inner element passes a check, otherwise
  /// return a failure Try with the supplied error.
  ///
  /// - Parameters:
  ///   - selector: Selector function.
  ///   - error: An Error instance.
  /// - Returns: A Try instance.
  func filter(_ selector: (Value) throws -> Bool, _ error: Error) -> Try<Value> {
    do {
      let value = try getOrThrow()
      return try selector(value) ? .success(value) : .failure(error)
    } catch {
      return .failure(error)
    }
  }

  /// Convenience method to filter out an inner element.
  ///
  /// - Parameters:
  ///   - selector: Selector function.
  ///   - error: A String value.
  /// - Returns: A Try instance.
  func filter(_ selector: (Value) throws -> Bool, _ error: String) -> Try<Value> {
    return filter(selector, FPError(error))
  }

  /// Convenience method to cast the inner value to a different type.
  ///
  /// - Parameter cls: Class type.
  /// - Returns: A Try instance.
  func cast<T>(_ cls: T.Type) -> Try<T> {
    return map({
      guard let tVal = $0 as? T else {
        throw FPError("\($0) is not of type \(cls)")
      }
      
      return tVal
    })
  }

  /// Functor.
  ///
  /// - Parameter f: Transform function.
  /// - Returns: A Try instance.
  func map<V1>(_ f: (Value) throws -> V1) -> Try<V1> {
    return Try({try f(self.getOrThrow())})
  }

  /// Applicative.
  ///
  /// - Parameter t: A TryConvertibleType instance.
  /// - Returns: A Try instance.
  func apply<T, V1>(_ t: T) -> Try<V1> where
    T: TryConvertibleType, T.Value == (Value) throws -> V1
  {
    return flatMap({a in t.asTry().map({try $0(a)})})
  }

  /// Monad.
  ///
  /// - Parameter f: Transform function.
  /// - Returns: A Try instance.
  func flatMap<T>(_ f: (Value) throws -> T) -> Try<T.Value> where T: TryConvertibleType {
    do {
      return try f(try getOrThrow()).asTry()
    } catch {
      return Try.failure(error)
    }
  }
}

public final class Try<Value> {
  public static func success(_ value: Value) -> Try<Value> {
    return Try(value)
  }

  public static func failure(_ error: Error) -> Try<Value> {
    return Try(error)
  }

  public static func failure(_ error: String) -> Try<Value> {
    return failure(FPError(error))
  }

  public let value: Value?
  public let error: Error?

  convenience public init(_ f: () throws -> Value) {
    do {
      self.init(try f())
    } catch {
      self.init(error)
    }
  }

  public init(_ value: Value) {
    self.value = value
    self.error = nil
  }

  public init(_ error: Error) {
    self.error = error
    self.value = nil
  }
}

extension Try: TryType {
  public func asTry() -> Try<Value> {
    return self
  }
}

// MARK: - OptionalConvertibleType
extension Try: OptionalConvertibleType {
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

public extension Try {
  
  /// Zip two Try instances to produce a Try of another type.
  ///
  /// - Parameters:
  ///   - try1: A TryConvertibleType instance.
  ///   - try2: A TryConvertibleType instance.
  ///   - f: Transform function.
  /// - Returns: A Try instance.
  static func zip<T1, T2, V3>(_ try1: T1, _ try2: T2, _ f: (T1.Value, T2.Value) throws -> V3)
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
  static func zip<TC, V2, S>(_ tries: S, _ resultSelector: ([TC.Value]) throws -> V2)
    -> Try<V2> where
    TC: TryConvertibleType,
    S: Sequence, S.Element == TC
  {
    do {
      let values = try tries.map({try $0.asTry().getOrThrow()})
      return try .success(resultSelector(values))
    } catch {
      return .failure(error)
    }
  }
  
  /// Zip a Sequence of TryConvertibleType with a result selector function.
  ///
  /// - Parameters:
  ///   - resultSelector: Selector function.
  ///   - tries: Varargs of TryConvertibleType.
  /// - Returns: A Try instance.
  static func zip<TC, V2>(_ resultSelector: ([TC.Value]) throws -> V2,
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
  func zipWith<TC, V2>(_ try2: TC, _ f: (Value, TC.Value) throws -> V2)
    -> Try<V2> where TC: TryConvertibleType
  {
    return flatMap({v1 in try2.asTry().map({try f(v1, $0)})})
  }
}

