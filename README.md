The `Try` enum
allows you to work with methods like `map` and `flatMap` but works
nicely with Swift's try/catch error handling mechanism when you actually
need to extract data.

A method can vend a `Try` object or pass it into a completion block.
When you need to get the represented value from the `Try` object
you just call `get()` from within a do/catch block.

```swift
let nameTry: Try<String> = contacts.fetchName()

do {
    let str = try nameTry.get()
    print("I got \(str)")
} catch {
    print("Error: \(error)")
}
```

Asynchronous code can easily pass the `Try` object into a completion block.
```swift
// Method to convert NSData to String
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
        let response: Try<String>

        if let error = responseError {
            // There was an error connecting to the server
            response = .Error(error)
        } else {
            // Create a String from the response data or pass along the error.
            response = Try<NSData>.value(data, orError: Error.Unknown).flatMap(convertData)
        }

        // hand off the response to the completion block
        completion(response)
    }

    if let task = task {
        task.resume()
    } else {
        completion(Try.Error(Error.Unknown))
    }
}

// Now call performRequest to fetch the contents of the url.
performRequest(url) { response in
    do {
        let str = try response.get()
        print("Got: \(str)")
    } catch {
        print("Error: \(error)")
    }
}
```
See `main.swift` for a working example of the above code.
