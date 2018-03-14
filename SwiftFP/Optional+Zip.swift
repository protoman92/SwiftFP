//
//  Optional+Zip.swift
//  SwiftFP
//
//  Created by Hai Pham on 14/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Optional {
    
    /// Zip a Sequence of OptionalConvertibleType with a resultSelector.
    ///
    /// - Parameters:
    ///   - optionals: A Sequence of OptionalConvertibleType.
    ///   - resultSelector: Selector function.
    /// - Returns: An Optional instance.
    public static func zip<W1,W2,OC,S>(_ optionals: S,
                                       _ resultSelector: ([W1]) throws -> W2)
        -> Optional<W2> where
        OC: OptionalConvertibleType, OC.Value == W1,
        S: Sequence, S.Element == OC
    {
        let tries = optionals.map({$0.asOptional().asTry()})
        return Try<W2>.zip(tries, resultSelector).value
    }
    
    /// Zip a Sequence of OptionalConvertibleType with a resultSelector.
    ///
    /// - Parameters:
    ///   - resultSelector: Selector function.
    ///   - optionals: Varargs of OptionalConvertibleType.
    /// - Returns: An Optional instance.
    public static func zip<W1,W2,OC>(_ resultSelector: ([W1]) throws -> W2,
                                     _ optionals: OC...) -> Optional<W2> where
        OC: OptionalConvertibleType, OC.Value == W1
    {
        return zip(optionals, resultSelector)
    }
    
    /// Zip with another Optional with a selector function.
    ///
    /// - Parameters:
    ///   - optional: An OptionalConvertibleType instance.
    ///   - resultSelector: Selector function.
    /// - Returns: An Optional instance.
    public func zipWith<W2,W3,OC>(_ optional: OC,
                                  _ resultSelector: (Wrapped, W2) throws -> W3)
        -> Optional<W3> where OC: OptionalConvertibleType, OC.Value == W2
    {
        return asTry().zipWith(optional.asOptional(), resultSelector).value
    }
}
