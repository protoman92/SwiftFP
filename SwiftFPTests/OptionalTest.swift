//
//  OptionalTest.swift
//  SwiftFPTests
//
//  Created by Hai Pham on 23/11/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

import XCTest
@testable import SwiftFP

public final class OptionalTest: XCTestCase {
  public func test_getOrElse_shouldWork() {
    /// Setup
    let o1 = Optional.some(1)
    let o2 = Optional<Int>.none

    /// When & Then
    XCTAssertEqual(o1.getOrElse(2), 1)
    XCTAssertEqual(o2.getOrElse(1), 1)
    XCTAssertEqual(try! o1.getOrThrow("Error"), 1)

    do {
      _ = try o2.getOrThrow("Error1")
      XCTFail("Should not complete")
    } catch let e {
      XCTAssertEqual(e.localizedDescription, "Error1")
    }
  }

  public func test_someOrElse_shouldWork() {
    /// Setup
    let o1 = Optional.some(1)
    let o2 = Try<Int>.failure(FPError(nil))
    let o3 = Optional.some(2)

    /// When & Then
    XCTAssertEqual(o1.someOrElse(o2), 1)
    XCTAssertEqual(o1.getOrElse(o3), 1)
    XCTAssertEqual(o2.asOptional().someOrElse(o1), 1)
  }

  public func test_optionalJustAndNothing_shouldWork() {
    /// Setup
    let o1 = Optional.just(1)
    let o2 = Optional<Int>.nothing()

    /// When & Then
    XCTAssertEqual(o1.value, 1)
    XCTAssertTrue(o2.isNothing)
  }

  public func test_optionalAsTry_shouldWork() {
    /// Setup
    let error = "Error"
    let o1 = Optional.some(1)
    let o2 = Optional<Int>.none

    /// When
    let t1 = o1.asTry(FPError(error))
    let t2 = o2.asTry(error)

    /// Then
    XCTAssertTrue(t1.isSuccess)
    XCTAssertEqual(t2.error?.localizedDescription, error)
  }

  public func test_zipOptional_shouldWork() {
    /// Setup
    let o1 = Try<Int>.failure(FPError(nil))
    let o2 = Optional.some(1)
    let o3 = Optional.some(2)
    let o4 = Optional.some(3)
    let o5 = Try.success(4)

    /// When
    let optional15 = Optional<Int>.zip({$0.reduce(0, +)}, o1, o5)
    let optional23 = o2.zipWith(o3, +)
    let optional234 = Optional<Int>.zip({$0.reduce(0, +)}, o2, o3, o4)
    let optional234E = Optional<Int>.zip([o2, o3, o4], {_ -> Int in throw FPError(nil)})
    let optional234V = Optional<Int>.zip({$0.reduce(0, +)}, o2, o3, o4)

    /// Then
    XCTAssertNil(optional15)
    XCTAssertEqual(optional23, 3)
    XCTAssertEqual(optional234, 6)
    XCTAssertEqual(optional234, optional234V)
    XCTAssertNil(optional234E)
  }

  public func test_optionalFilter_shouldWork() {
    /// Setup
    let o1 = Optional.some(1)
    let o2 = Optional.some(2)
    let o3 = Optional<Int>.nothing()

    /// When
    let o1f = o1.filter({$0 % 2 == 0})
    let o2f = o2.filter({$0 % 2 == 0})
    let o3f = o3.filter({$0 % 2 != 0})

    /// Then
    XCTAssertTrue(o1f.isNothing)
    XCTAssertTrue(o2f.isSome)
    XCTAssertTrue(o3f.isNothing)
  }

  public func test_optionalCast_shouldWork() {
    /// Setup
    let o1 = Optional.some(1)
    let o2 = Optional<Int>.nothing()

    /// When
    let o1c = o1.cast(Any.self)
    let o2c = o2.cast(Any.self)

    /// Then
    XCTAssertTrue(o1c.isSome)
    XCTAssertTrue(o2c.isNothing)
  }
}
