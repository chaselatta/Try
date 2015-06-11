//
//  TryTests.swift
//  TryTests
//
//  Created by Chase Latta on 6/11/15.
//  Copyright © 2015 Chase Latta. All rights reserved.
//

import XCTest

enum Error: ErrorType {
    case FirstError
    case SecondError
}

class TryTests: XCTestCase {
    let stringValue = Try.Value("hello")
    let intValue = Try.Value(1)
    let firstError = Try<String>.Error(Error.FirstError)
    let secondError = Try<String>.Error(Error.SecondError)
    
    func testGetStringValue() {
        var v = ""
        do {
            v = try stringValue.get()
        } catch {
        }
        XCTAssert(v == "hello")
    }
    
    func testGetIntValue() {
        var v: Int = 0
        do {
            v = try intValue.get()
        } catch {
        }
        XCTAssert(v == 1)
    }
    
    func testFirstError() {
        var hitError = false
        do {
            try firstError.get()
        } catch Error.FirstError {
            hitError = true
        } catch {
            
        }
        XCTAssertTrue(hitError)
    }
    
    func testSecondError() {
        var hitError = false
        do {
            try secondError.get()
        } catch Error.SecondError {
            hitError = true
        } catch {
            
        }
        XCTAssertTrue(hitError)
    }
    
    func testMapOnValue() {
        let mapped = stringValue.map { $0.characters.count }
        var passed = false
        
        do {
            let count = try mapped.get()
            passed = count == 5
        } catch {
            
        }
        
        XCTAssertTrue(passed)
    }
    
    func testMapOnError() {
        let mapped = firstError.map { $0.characters.count }
        var hitError = false
        
        do {
            try mapped.get()
        } catch {
            hitError = true
        }
        
        XCTAssertTrue(hitError)
    }
    
    func testFlatMapValue() {
        let flatmapped = stringValue.flatMap {
                Try<String>.Value($0.uppercaseString)
            }.flatMap {
                Try<Bool>.Value($0.hasPrefix("HELLO"))
            }
        
        var hasPrefix = false
        
        do {
            hasPrefix = try flatmapped.get()
        } catch {
            
        }
        
        XCTAssertTrue(hasPrefix)
    }
    
    func testFlatMapFirstError() {
        let flatmapped: Try<Bool> = stringValue.flatMap {_ in
                Try<String>.Error(Error.FirstError)
            }.flatMap {_ in
                Try<Bool>.Error(Error.SecondError)
        }
        
        var didError = false
        do {
            try flatmapped.get()
        } catch Error.FirstError {
            didError = true
        } catch {
            
        }
        
        XCTAssertTrue(didError)
    }
    
    func testFlatMapSecondError() {
        let flatmapped: Try<Bool> = stringValue.flatMap {
                Try<String>.Value($0.uppercaseString)
            }.flatMap {_ in
                Try<Bool>.Error(Error.SecondError)
        }
        
        var didError = false
        do {
            try flatmapped.get()
        } catch Error.SecondError {
            didError = true
        } catch {
            
        }
        
        XCTAssertTrue(didError)
    }
}
