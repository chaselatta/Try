//
//  main.swift
//  Try
//
//  Created by Chase Latta on 6/11/15.
//  Copyright © 2015 Chase Latta. All rights reserved.
//

import Foundation

enum Error: ErrorType {
    case Unknown
    case StringParsing
}

func performRequest(url: NSURL?, completion: Try<NSData> -> ()) {
    guard let url = url else { return }
    
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithURL(url) { (data, _, responseError) -> Void in
        let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(q) {
            var response: Try<NSData>
            
            if let error = responseError {
                response = Try.Error(error)
            } else if let data = data {
                response = Try.Value(data)
            } else {
                response = Try.Error(Error.Unknown)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(response)
            }
        }
    }
    
    if let task = task {
        task.resume()
    } else {
        completion(Try.Error(Error.Unknown))
    }
}


let url = NSURL(string: "https://www.google.com")

performRequest(url) { dataTry in
    let strTry = dataTry.flatMap({ data -> Try<String> in
        if let str = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
            return Try.Value(str)
        } else {
            return Try.Error(Error.StringParsing)
        }
    })
    
    do {
        let str = try strTry.get()
        print("Got: \(str)")
    } catch {
        print("Error: \(error)")
    }
}

dispatch_main()