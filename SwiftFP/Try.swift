//
//  Try.swift
//  SwiftFP
//
//  Created by Hai Pham on 7/8/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

/// Use this to wrap operations that can throw Error.
public protocol TryConvertibleType {
  associatedtype Val

  func asTry() -> Try<Val>
}

public protocol TryType: TryConvertibleType, EitherConvertibleType {

  /// Get the success value.
  var value: Val? { get }

  /// Get the failure error.
  var error: Error? { get }
}

public extension TryType {
  public func asEither() -> Either<Error, Val> {
    do {
      return Either.right(try getOrThrow())
    } catch let error {
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

  /// Get success value or throw failure Error.
  ///
  /// - Returns: A Val instance.
  /// - Throws: Error if success value if absent.
  public func getOrThrow() throws -> Val {
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
  /// - Parameter backup: A Val instance.
  /// - Returns: A Val instance.
  public func getOrElse(_ backup: Val) -> Val {
    if let value = self.value {
      return value
    } else {
      return backup
    }
  }

  /// Get the current Try if it is successful, or return another Try if not.
  ///
  /// - Parameter backup: A TryConvertibleType instance.
  /// - Returns: A Try instance.
  public func successOrElse<TC>(_ backup: TC) -> Try<Val> where
    TC: TryConvertibleType, TC.Val == Val
  {
    return isSuccess ? self.asTry() : backup.asTry()
  }
}

public extension TryType {

  /// Return the current Try if the inner element passes a check, otherwise
  /// return a failure Try with the supplied error.
  ///
  /// - Parameters:
  ///   - selector: Selector function.
  ///   - error: An Error instance.
  /// - Returns: A Try instance.
  public func filter(_ selector: (Val) throws -> Bool, _ error: Error) -> Try<Val> {
    do {
      let value = try getOrThrow()
      return try selector(value) ? Try.success(value) : Try.failure(error)
    } catch let e {
      return Try.failure(e)
    }
  }

  /// Convenience method to filter out an inner element.
  ///
  /// - Parameters:
  ///   - selector: Selector function.
  ///   - error: A String value.
  /// - Returns: A Try instance.
  public func filter(_ selector: (Val) throws -> Bool, _ error: String) -> Try<Val> {
    return filter(selector, FPError(error))
  }

  /// Convenience method to cast the inner value to a different type.
  ///
  /// - Parameter cls: Class type.
  /// - Returns: A Try instance.
  public func cast<T>(_ cls: T.Type) -> Try<T> {
    return map({
      if let tVal = $0 as? T {
        return tVal
      } else {
        throw FPError("\($0) is not of type \(cls)")
      }
    })
  }

  /// Functor.
  ///
  /// - Parameter f: Transform function.
  /// - Returns: A Try instance.
  public func map<A1>(_ f: (Val) throws -> A1) -> Try<A1> {
    return Try({try f(self.getOrThrow())})
  }

  /// Applicative.
  ///
  /// - Parameter t: A TryConvertibleType instance.
  /// - Returns: A Try instance.
  public func apply<T, A1>(_ t: T) -> Try<A1> where
    T: TryConvertibleType, T.Val == (Val) throws -> A1
  {
    return flatMap({a in t.asTry().map({try $0(a)})})
  }

  /// Monad.
  ///
  /// - Parameter f: Transform function.
  /// - Returns: A Try instance.
  public func flatMap<T, Val2>(_ f: (Val) throws -> T) -> Try<Val2> where
    T: TryConvertibleType, T.Val == Val2
  {
    do {
      return try f(try getOrThrow()).asTry()
    } catch let error {
      return Try.failure(error)
    }
  }
}

public final class Try<A> {
  public static func success(_ value: A) -> Try<A> {
    return Try(value)
  }

  public static func failure(_ error: Error) -> Try<A> {
    return Try(error)
  }

  public static func failure(_ error: String) -> Try<A> {
    return failure(FPError(error))
  }

  public let value: A?
  public let error: Error?

  convenience public init(_ f: () throws -> A) {
    do {
      self.init(try f())
    } catch let e {
      self.init(e)
    }
  }

  public init(_ value: A) {
    self.value = value
    self.error = nil
  }

  public init(_ error: Error) {
    self.error = error
    self.value = nil
  }
}

extension Try: TryType {
  public func asTry() -> Try<A> {
    return self
  }
}
