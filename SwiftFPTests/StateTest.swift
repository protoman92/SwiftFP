//
//  StateTest.swift
//  SwiftUtilities
//
//  Created by Hai Pham on 7/10/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import XCTest
@testable import SwiftFP

public final class StateTest: XCTestCase {
    public func test_stateMonad_shouldWork() {
        //// Setup
        let s1 = State<Int, Int>({($0, $0)}).modify({$0 * 2}).map({$0 * 3})
        
        let s2 = s1.flatMap({(a) -> State<Int, Int> in
            if a % 2 == 0 {
                return State<Int, Int>({($0, $0)})
            } else {
                return State<Int, Int>({($0 * 2, $0 * 2)})
            }
        })
        
        /// When & Then
        for i in 0..<1000 {
            do {
                let (s1, a1) = try s1.run(i)
                let (s2, a2) = try s2.run(i)
                XCTAssertEqual(s2, a2)
                XCTAssertEqual(s1, i * 2)
                XCTAssertEqual(a1, i * 3)
                
                if a1 % 2 == 0 {
                    XCTAssertEqual(s1, s2)
                } else {
                    XCTAssertEqual(s1 * 2, s2)
                }
            } catch let error {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}
