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
        let fInt: Function<Int> = {value}
        
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
        
        let fInt: Function<Int> = {
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
        
        let fInt: Function<Int> = {
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
        XCTAssertLessThan((difference / 10 - duration) / duration, 0.05)
        XCTAssertEqual(actualError?.localizedDescription, error)
    }
    
    public func test_multipleComposition_shouldWork() {
        /// Setup
        var actualError: Error?
        var publishCount = 0
        let error = "Error"
        let retryCount = 10
        let fInt: Function<Int> = {throw FPError.any(error)}
        let publishF: (Error) -> Void = {_ in publishCount += 1}
        
        /// When & Then 1
        do {
            _ = try Composable<Int>.publishError(publishF)
                .compose(Composable.retry(retryCount))
                .invoke(fInt)()
        } catch let e {
            actualError = e
        }
        
        XCTAssertEqual(actualError?.localizedDescription, error)
        XCTAssertEqual(publishCount, 1)
        
        /// When & Then 2
        actualError = nil
        publishCount = 0
        
        do {
            _ = try Composable<Int>.retry(retryCount)
                .compose(Composable.publishError(publishF))
                .invoke(fInt)()
        } catch let e {
            actualError = e
        }
        
        XCTAssertEqual(actualError?.localizedDescription, error)
        XCTAssertEqual(publishCount, retryCount + 1)
    }
}
