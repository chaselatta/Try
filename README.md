This is an experiment in creating an object that captures data and
errors to be passed through asynchronous functions. The `Try` enum
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

Asynchronous code can easily pass the `Try` object into a completion
block.
```swift 
performRequest(url) { response in
    do {
        let str = try response.get()
        print("Got: \(str)")
    } catch {
        print("Error: \(error)")
    }
}
```
