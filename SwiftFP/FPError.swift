//
//  FPError.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

// Utility errors for FP data structures.
public enum FPError {
    case any(String?)
    case optional(String?)
    case `try`(String?)
    
    public var message: String? {
        switch self {
        case .any(let msg):
            return msg
            
        case .optional(let msg):
            return msg
            
        case .`try`(let msg):
            return msg
        }
    }
}

extension FPError: Error {}

extension FPError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
    
    public var failureReason: String? {
        return message
    }
}
