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
    case HTTPBadRequest
    case HTTPInternalServerError
    case StringParsing
}

func errorForResponse(response: NSURLResponse?) -> ErrorType? {
    guard let response = response as? NSHTTPURLResponse else {
        return Error.Unknown
    }
    
    switch response.statusCode {
    case 0..<400:
        return nil
    case 400..<500:
        return Error.HTTPBadRequest
    case 500..<600:
        return Error.HTTPInternalServerError
    default:
        return Error.Unknown
    }
}

func validateResponse(response: NSURLResponse?)(value: NSData) -> Try<NSData> {
    if let error = errorForResponse(response) {
        return .Error(error)
    } else {
        return .Value(value)
    }
}

func convertData(data: NSData) -> Try<String> {
    if let str = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
        return .Value(str)
    } else {
        return .Error(Error.StringParsing)
    }
}

func performRequest(url: NSURL?, completion: Try<String> -> ()) {
    guard let url = url else { return }
    
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithURL(url) { (data, URLResponse, responseError) -> Void in
        let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(q) {
            let response: Try<String>
            
            if let error = responseError {
                response = .Error(error)
            } else {
                response = Try<NSData>.value(data, orError: Error.Unknown)
                    .flatMap(validateResponse(URLResponse))
                    .flatMap(convertData)
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

performRequest(url) { response in
    do {
        let str = try response.get()
        print("Got: \(str)")
    } catch {
        print("Error: \(error)")
    }
}

dispatch_main()