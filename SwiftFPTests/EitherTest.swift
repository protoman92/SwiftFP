//
//  EitherTest.swift
//  SwiftFPTests
//
//  Created by Hai Pham on 7/8/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import XCTest
@testable import SwiftFP

public final class EitherTest: XCTestCase {
  public func test_eitherMonad_shouldWork() {
    /// Setup
    let e1 = Either<Int, Double>.left(1)
    let e2 = Either<Int, Double>.right(2)

    // When & Then
    XCTAssertEqual(e1.projection.left.map(Double.init).left, 1)
    XCTAssertEqual(e1.projection.right.map(Int.init).right, nil)
    XCTAssertEqual(e2.projection.left.map(Double.init).left, nil)
    XCTAssertEqual(e2.projection.right.map(Int.init).right, 2)
  }

  public func test_eitherBimap_shouldWork() {
    /// Setup
    let e1 = Either<Int, Double>.left(1)
    let e2 = Either<Int, Double>.right(2)
    let f1: (Int) -> String = String.init
    let f2: (Double) -> Int = Int.init
    let e11 = e1.bimap(f1, f2)
    let e21 = e2.bimap(f1, f2)

    // When & Then
    XCTAssertEqual(e11.left, "1")
    XCTAssertEqual(e11.right, nil)
    XCTAssertEqual(e21.left, nil)
    XCTAssertEqual(e21.right, 2)
  }
}
