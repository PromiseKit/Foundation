// swift-tools-version:4.0
// temporarily require swift 4.0 so the .branch specifier below will work, remove these 2 lines before integrating
import PackageDescription

let package = Package(
    name: "PMKFoundation",
    dependencies: [
//      .Package(url: "https://github.com/mxcl/PromiseKit.git", majorVersion: 6)
        .Package(url: "https://github.com/dougzilla32/PromiseKit.git", .branch("PMKCancel")),
//      .Package(url: "https://github.com/PromiseKit/Cancel.git", majorVersion: 1),
        .Package(url: "https://github.com/dougzilla32/Cancel.git", majorVersion: 1)
    ],
    exclude: [
        "Sources/NSNotificationCenter+AnyPromise.m",
        "Sources/NSTask+AnyPromise.m",
        "Sources/NSURLSession+AnyPromise.m",
        "Sources/PMKFoundation.h",
		"Tests"  // currently SwiftPM is not savvy to having a single test…
    ]
)

#if os(Linux)
package.exclude += [
    "Sources/afterlife.swift",
    "Sources/NSObject+Promise.swift"
]
#endif
