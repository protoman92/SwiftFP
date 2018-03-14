//
//  OptionalTest.swift
//  SwiftUtilitiesTests
//
//  Created by Hai Pham on 23/11/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

import XCTest
@testable import SwiftFP

public final class OptionalTest: XCTestCase {
    public func test_zipOptional_shouldWork() {
        /// Setup
        let o1 = Try<Int>.failure(FPError.any(nil))
        let o2 = Optional.some(1)
        let o3 = Optional.some(2)
        let o4 = Optional.some(3)
        let o5 = Try.success(4)
        
        /// When
        let optional15 = Optional<Int>.zip([o1, o5], {$0.reduce(0, +)})
        let optional234 = Optional<Int>.zip([o2, o3, o4], {$0.reduce(0, +)})
        let optional234E = Optional<Int>.zip([o2, o3, o4], {_ -> Int in throw FPError.any(nil)})
        let optional234V = Optional<Int>.zip({$0.reduce(0, +)}, o2, o3, o4)
        
        /// Then
        XCTAssertNil(optional15)
        XCTAssertEqual(optional234, 6)
        XCTAssertEqual(optional234, optional234V)
        XCTAssertNil(optional234E)
    }
    
    public func test_getOrElse_shouldWork() {
        /// Setup
        let o1 = Optional.some(1)
        let o2 = Try<Int>.failure(FPError.any(nil))
        let o3 = Optional.some(2)
        
        /// When
        let o12 = o1.getOrElse(o2)
        let o13 = o1.getOrElse(o3)
        let o21 = o2.getOrElse(o1)
        
        /// Then
        XCTAssertEqual(o12, 1)
        XCTAssertEqual(o13, 1)
        XCTAssertEqual(o21, 1)
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
        XCTAssertTrue(o1f.isNothing())
        XCTAssertTrue(o2f.isSome())
        XCTAssertTrue(o3f.isNothing())
    }
}
