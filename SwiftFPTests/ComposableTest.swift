//
//  ComposableTest.swift
//  SwiftFPTests
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import SwiftFP

public final class ComposableTest: XCTestCase {
    public func test_composePublish_shouldWork() {
        /// Setup
        var published = 0
        var publishedValue = 0
        let value = 1
        let fInt: Supplier<Int> = {value}
        
        let publishF: (Int) -> Void = {
            published += 1
            publishedValue = $0
        }
        
        let publishC = Composable.publish(publishF)
        
        /// When
        let result = try! publishC.invoke(fInt)()
        
        /// Then
        XCTAssertEqual(result, value)
        XCTAssertEqual(publishedValue, value)
        XCTAssertEqual(published, 1)
    }
    
    public func test_composeRetry_shouldWork() {
        /// Setup
        var actualError: Error?
        var actualTryCount = 0
        let retryCount = 0
        let error = "Error!"
        
        let fInt: Supplier<Int> = {
            actualTryCount += 1
            throw FPError.any(error)
        }
        
        let retryF = Composable<Int>.retry(retryCount)
        
        /// When
        do {
            _ = try retryF.invoke(fInt)()
        } catch let e {
            actualError = e
        }
        
        /// Then
        XCTAssertEqual(actualTryCount, retryCount + 1)
        XCTAssertEqual(actualError?.localizedDescription, error)
    }
    
    public func test_composeRetryWithDelay_shouldWork() {
        /// Setup
        var actualError: Error?
        var actualTryCount = 0
        let retryCount = 10
        let duration: TimeInterval = 0.2
        let error = "Error!"
        
        let fInt: Supplier<Int> = {
            actualTryCount += 1
            throw FPError.any(error)
        }
        
        let retryF = Composable<Int>.retryWithDelay(retryCount)(duration)
        
        /// When
        let start = Date()
        
        do {
            _ = try retryF.invoke(fInt)()
        } catch let e {
            actualError = e
        }
        
        let difference = Date().timeIntervalSince(start)
        
        /// Then
        XCTAssertEqual(actualTryCount, retryCount + 1)
        XCTAssertLessThan((difference / 10 - duration) / duration, 0.1)
        XCTAssertEqual(actualError?.localizedDescription, error)
    }
    
    public func test_composeTimeout_shouldWork() {
        /// Setup
        var actualError1: Error?
        var actualError2: Error?
        var actualResult1: Int?
        var actualResult2: Int?
        let timeout: TimeInterval = 1
        let dispatchQueue = DispatchQueue.global(qos: .background)
        
        let fInt1: Supplier<Int> = {
            Thread.sleep(forTimeInterval: timeout * 2)
            return 1
        }
        
        let fInt2: Supplier<Int> = {
            Thread.sleep(forTimeInterval: timeout / 2)
            return 2
        }
        
        let timeoutF = Composable<Int>.timeout(timeout)(dispatchQueue)
        
        /// When
        do {
            actualResult1 = try timeoutF.invoke(fInt1)()
        } catch let e {
            actualError1 = e
        }
        
        do {
            actualResult2 = try timeoutF.invoke(fInt2)()
        } catch let e {
            actualError2 = e
        }
        
        /// Then
        XCTAssertTrue(actualError1 is FPError)
        XCTAssertNil(actualResult1)
        XCTAssertNil(actualError2)
        XCTAssertEqual(actualResult2, 2)
    }
    
    public func test_composeCatch_shouldWork() {
        /// Setup
        var actualError: Error?
        var actualResult: Int?
        let fInt: Supplier<Int> = {throw FPError.any("")}
        
        /// When
        do {
            actualResult = try Composable.catch({_ in 1}).invoke(fInt)()
        } catch let e {
            actualError = e
        }
        
        /// Then
        XCTAssertNil(actualError)
        XCTAssertEqual(actualResult, 1)
    }
    
    public func test_composableCatchWithoutError_shouldWork() {
        /// Setup
        var actualError: Error?
        var actualResult: Int?
        let fInt: Supplier<Int> = {1}
        
        /// When
        do {
            actualResult = try Composable.catchReturn(100).invoke(fInt)()
        } catch let e {
            actualError = e
        }
        
        /// Then
        XCTAssertNil(actualError)
        XCTAssertEqual(actualResult, 1)
    }
    
    public func test_composeCatchThrows_shouldWork() {
        /// Setup
        var actualError: Error?
        var actualResult: Int?
        let fInt: Supplier<Int> = {throw FPError.any("")}
        
        /// When
        do {
            actualResult = try Composable.catch({throw $0}).invoke(fInt)()
        } catch let e {
            actualError = e
        }
        
        /// Then
        XCTAssertNotNil(actualError)
        XCTAssertTrue(actualError is FPError)
        XCTAssertNil(actualResult)
    }
    
    public func test_multipleComposition_shouldWork() {
        /// Setup
        var actualError: Error?
        var actualResult: Int?
        var publishCount = 0
        let error = "Error"
        let retryCount = 10
        let dispatchQueue = DispatchQueue.global(qos: .background)
        let fInt: Supplier<Int> = {throw FPError.any(error)}
        let publishF: (Error) -> Void = {_ in publishCount += 1}
        
        let reset: () -> Void = {
            actualError = nil
            actualResult = nil
            publishCount = 0
        }
        
        /// When & Then 1
        do {
            actualResult = try Composable<Int>.publishError(publishF)
                .compose(Composable.retry(retryCount))
                .compose(Composable.timeout(10)(dispatchQueue))
                .invoke(fInt)()
        } catch let e {
            actualError = e
        }
        
        XCTAssertEqual(actualError?.localizedDescription, error)
        XCTAssertNil(actualResult)
        XCTAssertEqual(publishCount, 1)
        
        /// When & Then 2
        reset()
        
        do {
            actualResult = try Composable<Int>.retry(retryCount)
                .compose(Composable.publishError(publishF))
                .compose(Composable.timeout(10)(dispatchQueue))
                .invoke(fInt)()
        } catch let e {
            actualError = e
        }
        
        XCTAssertEqual(actualError?.localizedDescription, error)
        XCTAssertNil(actualResult)
        XCTAssertEqual(publishCount, retryCount + 1)
        
        /// When & Then 3
        reset()
        
        do {
            actualResult = try Composable<Int>.retry(100000)
                .compose(Composable.retry(100000))
                .compose(Composable.publishError(publishF))
                .compose(Composable.timeout(2)(dispatchQueue))
                .compose(Composable.catchReturn(1)) // Nullify all above.
                .invoke(fInt)()
        } catch let e {
            actualError = e
        }
        
        XCTAssertNil(actualError)
        XCTAssertEqual(actualResult, 1)
        XCTAssertEqual(publishCount, 0)
    }
}
