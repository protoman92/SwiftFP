//
//  ReaderTest.swift
//  SwiftUtilities
//
//  Created by Hai Pham on 7/8/17.
//  Copyright © 2017 Swiften. All rights reserved.
//

import XCTest
@testable import SwiftFP

public final class ReaderTest: XCTestCase {
    public func test_readerMonad_shouldWorkWithDifferentInjection() {
        //// Setup
        let r1 = IntReader({$0 * 2})
        let r2 = Reader<Int, String>({$0.description})
        
        /// When & Then
        XCTAssertEqual(try r1.run(1), 2)
        XCTAssertEqual(try r1.run(2), 4)
        XCTAssertEqual(try r2.run(1), "1")
        XCTAssertEqual(try r2.run(2), "2")
        XCTAssertEqual(try r2.map({Int($0)}).run(2), 2)
        XCTAssertEqual(try r1.flatMap({i in IntReader({$0 * i})}).run(2), 8)
        XCTAssertEqual(try r2.flatMap({i in IntReader({$0})}).run(2), 2)
    }
    
    public func test_readerZip_shouldWork() {
        //// Setup
        let r1 = Reader<Int, Int>({$0 * 2})
        let r2 = Reader<Int, Int>({$0 * 3})
        let z1 = r1.zip(with: r2, {$0 * $1})
        
        let r3 = Reader<Double, Double>({$0 * 5})
        let z2 = r1.zip(with: r3, {Double($0) + $1})
        let r4 = Reader<Int, Int>.zip({$0.reduce(0, +)}, r1, r2, z1)
        
        /// When & Then
        for i in 0..<1000 {
            XCTAssertEqual(try z1.run(i), i * i * 2 * 3)
            XCTAssertEqual(try z2.run((i, Double(i * 2))), Double(i * 2 + i * 2 * 5))
            XCTAssertEqual(try r4.run(i), i * 2 + i * 3 + i * i * 6)
        }
    }
    
    public func test_readerZipIgnoringErrors_shouldWork() {
        //// Setup
        let r1 = Reader<Int, Int>({_ in throw FPError.any("Error1") })
        let r2 = Reader<Int, Int>({_ in throw FPError.any("Error2") })
        let r3 = Reader<Int, Int>({$0})
        let r4 = Reader<Int, Int>({$0 * 2})
        let z1 = Reader<Int, Int>.zip([r1, r2, r3, r4], {$0.reduce(0, +)})
        let z2 = Reader<Int, Int>.zip({$0.reduce(0, +)}, ignoringErrors: r1, r2, r3, r4)
        
        /// When & Then
        for i in 0..<1000 {
            XCTAssertThrowsError(try z1.run(i))
            XCTAssertEqual(try z2.run(i), i + i * 2)
        }
    }
    
    public func test_readerModify_shouldWork() {
        //// Setup
        let r1 = Reader<Int, Double>(Double.init)
        let r2 = Reader<String, Int?>({Int($0)}).map({$0 ?? 0})
        let r12: Reader<Double, Double> = r1.modify(Int.init)
        let r22: Reader<Int, Int> = r2.modify(String.init)
        
        /// When & Then
        for i in 0..<1000 {
            XCTAssertEqual(try r12.run(Double(i)), Double(i))
            XCTAssertEqual(try r22.run(i), i)
        }
    }
}

fileprivate final class IntReader {
    fileprivate let f: (Int) throws -> Int
    
    init(_ f: @escaping (Int) throws -> Int) {
        self.f = f
    }
}

extension IntReader: ReaderType {
    func asReader() -> Reader<Int, Int> {
        return Reader(f)
    }
}
