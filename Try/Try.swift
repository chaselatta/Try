//
//  Try.swift
//  Try
//
//  Created by Chase Latta on 6/11/15.
//  Copyright © 2015 Chase Latta. All rights reserved.
//

import Foundation

enum Try<T> {
    /// When the Try represents a value
    case Value(T)
    
    /// When the Try represents an error. 
    /// The Error will be thrown when _get_ is called.
    case Error(ErrorType)
    
    /**
        Call this method to get the value if it exists
        or throw the error
    */
    func get() throws ->  T {
        switch self {
        case .Value(let v):
            return v
        case .Error(let e):
            throw e
        }
    }
    
    /// Transforms T -> U if the Try represents a value
    func map<U>(@noescape f: T -> U) -> Try<U> {
        do {
            let value = try get()
            return Try<U>.Value(f(value))
        } catch {
            return Try<U>.Error(error)
        }
    }
    
    /// Calls map on the flattened Try
    func flatMap<U>(@noescape f: T -> Try<U>) -> Try<U> {
        return Try<U>.flatten(map(f))
    }
    
    private static func flatten<U>(result: Try<Try<U>>) -> Try<U> {
        switch result {
        case .Value(let inner):
            return inner
        case .Error(let error):
            return Try<U>.Error(error)
        }
    }
}

