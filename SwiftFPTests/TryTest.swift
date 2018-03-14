//
//  TryTest.swift
//  SwiftUtilities
//
//  Created by Hai Pham on 7/8/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import XCTest
@testable import SwiftFP

public final class TryTest: XCTestCase {
    public func test_tryMonad_shouldWork() {
        /// Setup
        let t1 = Try<Int>({ throw FPError.try("Error1") })
        let t2 = Try<Int>({1})
        
        // When & Then
        XCTAssertEqual(t1.map({Double($0 * 2)}).value, nil)
        XCTAssertEqual(t1.flatMap({a in Try({a})}).value, nil)
        XCTAssertEqual(t2.map({Double($0 * 3)}).value, 3)
        XCTAssertEqual(t2.flatMap({a in Try({a})}).value, 1)
    }
    
    public func test_tryToEither_shouldWork() {
        /// Setup
        let t1 = Try<Int>({ throw FPError.try("Error1") })
        let t2 = Try<Int>({1})
        let e1 = t1.asEither()
        let e2 = t2.asEither()
        
        // When & Then
        XCTAssertTrue(e1.isLeft)
        XCTAssertEqual(e1.left!.localizedDescription, "Error1")
        XCTAssertTrue(e2.isRight)
        XCTAssertEqual(e2.right, 1)
    }
    
    public func test_tryZipWith_shouldWork() {
        /// Setup
        let try1 = Try.success(1)
        let try2 = Try.success("1")
        let try3 = Try<String>.failure(FPError.try(nil))
        let try4 = Try.success(2.5)
        
        /// When
        let try12 = try1.zipWith(try2, {String(describing: $0) + $1})
        let try23 = try2.zipWith(try3, {$0 + $1})
        let try34 = try3.zipWith(try4, {$0 + String(describing: $1)})
        
        /// Then
        XCTAssertTrue(try12.isSuccess)
        XCTAssertEqual(try12.value, "11")
        XCTAssertTrue(try23.isFailure)
        XCTAssertTrue(try34.isFailure)
    }
    
    public func test_tryFilter_shouldWork() {
        /// Setup
        let try1 = Try.success(1)
        let try2 = Try.success(2)
        let try3 = Try<Int>.failure(FPError.try("Error 3"))

        /// Setup
        let try1f = try1.filter({$0 % 2 == 0}, "Not even!")
        let try2f = try2.filter({$0 % 2 == 0}, "Not even!")
        let try3f = try3.filter({$0 % 2 != 0}, "This error should be be reached")
        
        /// Then
        XCTAssertTrue(try1f.isFailure)
        XCTAssertTrue(try2f.isSuccess)
        XCTAssertEqual(try3f.error?.localizedDescription, "Error 3")
    }
}
