//
//  Optional+Try.swift
//  SwiftFP
//
//  Created by Hai Pham on 31/7/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

extension Optional: TryConvertibleType {
  public typealias Val = Wrapped

  /// Convert this Optional into a Try.
  ///
  /// - Returns: A Try instance.
  public func asTry() -> Try<Val> {
    return Try<Val>.from(self)
  }

  /// Convert this Optional into a Try.
  ///
  /// - Parameter error: An Error instance.
  /// - Returns: A Try instance.
  public func asTry(_ error: Error) -> Try<Val> {
    return Try<Val>.from(self, error)
  }

  /// Convert this Optional into a Try.
  ///
  /// - Parameter error: A String value.
  /// - Returns: A Try instance.
  public func asTry(_ error: String) -> Try<Val> {
    return asTry(FPError(error))
  }
}
