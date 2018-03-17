//
//  TryTest.swift
//  SwiftFP
//
//  Created by Hai Pham on 7/8/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import XCTest
@testable import SwiftFP

public final class TryTest: XCTestCase {
  public func test_tryInit_shouldWork() {
    /// Setup
    let t1 = Try(1)
    let t2 = Try<Int>(FPError("Error"))

    /// When & Then
    XCTAssertEqual(t1.value, 1)
    XCTAssertNil(t1.error)
    XCTAssertNil(t2.value)
    XCTAssertNotNil(t2.error)
  }

  public func test_tryMonad_shouldWork() {
    /// Setup
    let t1 = Try<Int>({ throw FPError("Error1") })
    let t2 = Try<Int>({1})

    // When & Then
    XCTAssertEqual(t1.map({Double($0 * 2)}).value, nil)
    XCTAssertEqual(t1.flatMap({a in Try({a})}).value, nil)
    XCTAssertEqual(t2.map({Double($0 * 3)}).value, 3)
    XCTAssertEqual(t2.flatMap({a in Try({a})}).value, 1)
    XCTAssertNotNil(t2.flatMap({(_) -> Try<Int> in throw FPError("")}).error)
  }

  public func test_tryGetOrElse_shouldWork() {
    /// Setup
    let t1 = Try.success(1)
    let t2 = Try<Int>.failure(FPError("Error 1"))
    let t3 = Try<Int>.failure(FPError("Error 2"))

    /// When & Then
    XCTAssertEqual(t1.getOrElse(2), 1)
    XCTAssertEqual(t2.getOrElse(1), 1)
    XCTAssertEqual(t3.successOrElse(t1).value, t1.value)
    XCTAssertEqual(t1.successOrElse(Optional.some(3)).value, t1.value)
  }

  public func test_tryToOptional_shouldWork() {
    /// Setup
    let o1 = Try.success(1).asOptional()
    let o2 = Try<Int>.failure("Nothing").asOptional()

    /// When & Then
    XCTAssertEqual(o1.value, 1)
    XCTAssertTrue(o2.isNothing)
  }

  public func test_tryToEither_shouldWork() {
    /// Setup
    let t1 = Try<Int>({ throw FPError("Error1") })
    let t2 = Try<Int>({1})
    let e1 = t1.asEither()
    let e2 = t2.asEither()

    // When & Then
    XCTAssertTrue(e1.isLeft)
    XCTAssertEqual(e1.left!.localizedDescription, "Error1")
    XCTAssertTrue(e2.isRight)
    XCTAssertEqual(e2.right, 1)
  }

  public func test_tryZip_shouldWork() {
    /// Setup
    let t1 = Try(1)
    let t2 = Try.success("1")
    let t3 = Try<String>.failure(FPError(nil))
    let t4 = Try.success(2.5)

    /// When
    let t12 = t1.zipWith(t2, {String(describing: $0) + $1})
    let t23 = Try<String>.zip(t2, t3, {$0 + $1})
    let t34 = t3.zipWith(t4, {$0 + String(describing: $1)})

    let t124 = Try<String>.zip({$0.reduce("", +)},
                               t1.map({String(describing: $0)}),
                               t2,
                               t4.map({String(describing: $0)}))

    let t1234 = Try<String>.zip([t1.map({String(describing: $0)}),
                                 t2, t3,
                                 t4.map({String(describing: $0)})],
                                {$0.reduce("", +)})

    /// Then
    XCTAssertTrue(t12.isSuccess)
    XCTAssertEqual(t12.value, "11")
    XCTAssertTrue(t23.isFailure)
    XCTAssertTrue(t34.isFailure)
    XCTAssertNotNil(t124.value)
    XCTAssertNotNil(t1234.error)
  }

  public func test_tryFilter_shouldWork() {
    /// Setup
    let try1 = Try.success(1)
    let try2 = Try.success(2)
    let try3 = Try<Int>.failure("Error 3")

    /// Setup
    let try1f = try1.filter({$0 % 2 == 0}, "Not even!")
    let try2f = try2.filter({$0 % 2 == 0}, "Not even!")
    let try3f = try3.filter({$0 % 2 != 0}, "This error should be be reached")

    /// Then
    XCTAssertTrue(try1f.isFailure)
    XCTAssertTrue(try2f.isSuccess)
    XCTAssertEqual(try3f.error?.localizedDescription, "Error 3")
  }

  public func test_tryCast_shouldWork() {
    /// Setup
    let t1 = Try.success(1)
    let t2 = Try<Int>.failure("Error!")

    /// When
    let t1c = t1.cast(Any.self)
    let t2c = t2.cast(Any.self)

    /// Then
    XCTAssertTrue(t1c.isSuccess)
    XCTAssertTrue(t2c.isFailure)
  }
}
