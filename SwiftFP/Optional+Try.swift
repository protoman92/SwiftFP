//
//  Optional+Try.swift
//  SwiftFP
//
//  Created by Hai Pham on 31/7/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

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
