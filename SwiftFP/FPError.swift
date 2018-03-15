//
//  FPError.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

// Utility errors for FP data structures.
public struct FPError {
    private let message: String?
    
    public init(_ message: String?) {
        self.message = message
    }
}

extension FPError: Error {}

extension FPError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
}
