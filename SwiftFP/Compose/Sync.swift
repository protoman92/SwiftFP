//
//  Sync.swift
//  SwiftFP
//
//  Created by Hai Pham on 15/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// AsyncCallback represents a callback for an asynchronous function.
public typealias AsyncCallback<T> = (Try<T>) -> Void

/// AsyncOperation represents an asynchronous operation.
public typealias AsyncOperation<T> = (@escaping AsyncCallback<T>) -> Void

public extension Composable {
    
    /// Synchronize the result of an async operation. It is important that the
    /// calling queue and perform queue have the same constraints as those
    /// spelled out in Composable.timeout(). The returned Supplier can then be
    /// fed to other Composables.
    ///
    /// - Parameter callbackFn: An AsyncCallback instance.
    /// - Returns: A Supplier instance.
    public static func sync(_ callbackFn: @escaping AsyncOperation<T>) -> Supplier<T> {
        return {
            let mutex = NSLock()
            var result: Try<T>?

            let setResult: (Try<T>) -> Void = {(r: Try<T>) in
                mutex.lock()
                defer { mutex.unlock() }
                result = r
            }

            let callback: AsyncCallback<T> = {(v: Try<T>) -> Void in
                setResult(v)
            }
            
            callbackFn(callback)
            while result == nil {}
            return try result!.getOrThrow()
        }
    }
}
