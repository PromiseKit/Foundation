# PromiseKit Foundation Extensions ![Build Status]

This project adds promises to the Swift Foundation framework.

We support iOS, tvOS, watchOS, macOS and Linux, Swift 3.0, 3.1 and 3.2.

This project does not currently support Linux, but PRs welcome.

## CococaPods

```ruby
pod "PromiseKit/Foundation", "~> 4.0"
```

The extensions are built into `PromiseKit.framework` thus nothing else is needed.

## Carthage

```ruby
github "PromiseKit/Foundation" ~> 1.0
```

The extensions are built into their own framework:

```swift
// swift
import PromiseKit
import PMKFoundation
```

```objc
// objc
@import PromiseKit;
@import PMKFoundation;
```

## SwiftPM

```swift
let package = Package(
    dependencies: [
        .Package(url: "https://github.com/PromiseKit/Foundation.git", majorVersion: 1)
    ]
)
```


[Build Status]: https://travis-ci.org/PromiseKit/Foundation.svg?branch=master
