import PMKFoundation
import OHHTTPStubs
import PromiseKit
import XCTest

class NSURLSessionTests: XCTestCase {
    func test1() {
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }

        let ex = expectation(description: "")
        let rq = URLRequest(url: URL(string: "http://example.com")!)
        firstly {
            URLSession.shared.dataTask(.promise, with: rq)
        }.compactMap {
            try JSONSerialization.jsonObject(with: $0.data) as? NSDictionary
        }.done { rsp in
            XCTAssertEqual(json, rsp)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func test2() {

        // test that URLDataPromise chains thens
        // this test because I don’t trust the Swift compiler

        let dummy = ("fred" as NSString).data(using: String.Encoding.utf8.rawValue)!

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(data: dummy, statusCode: 200, headers: [:])
        }

        let ex = expectation(description: "")
        let rq = URLRequest(url: URL(string: "http://example.com")!)

        after(.milliseconds(100)).then {
            URLSession.shared.dataTask(.promise, with: rq)
        }.done { x in
            XCTAssertEqual(x.data, dummy)
            ex.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    /// test that our convenience String constructor applies
    func test3() {
        let dummy = "fred"

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            let data = dummy.data(using: .utf8)!
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: [:])
        }

        let ex = expectation(description: "")
        let rq = URLRequest(url: URL(string: "http://example.com")!)

        after(.milliseconds(100)).then {
            URLSession.shared.dataTask(.promise, with: rq)
        }.map(String.init).done {
            XCTAssertEqual($0, dummy)
            ex.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }
}

//////////////////////////////////////////////////////////// Cancellation

extension NSURLSessionTests {
    func testCancel1() {
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }

        let ex = expectation(description: "")
        let rq = URLRequest(url: URL(string: "http://example.com")!)
        let context = firstly {
            cancellable(URLSession.shared.dataTask(.promise, with: rq))
        }.compactMap {
            try JSONSerialization.jsonObject(with: $0.data) as? NSDictionary
        }.done { rsp in
            XCTAssertEqual(json, rsp)
            XCTFail("failed to cancel session")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("Error: \(error)")
        }.cancelContext
        context.cancel()
        waitForExpectations(timeout: 1)
    }

    func testCancel2() {

        // test that URLDataPromise chains thens
        // this test because I don’t trust the Swift compiler

        let dummy = ("fred" as NSString).data(using: String.Encoding.utf8.rawValue)!

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(data: dummy, statusCode: 200, headers: [:])
        }

        let ex = expectation(description: "")
        let rq = URLRequest(url: URL(string: "http://example.com")!)

        let context = cancellable(after(.milliseconds(100))).then {
            cancellable(URLSession.shared.dataTask(.promise, with: rq))
        }.done { x in
            XCTAssertEqual(x.data, dummy)
            ex.fulfill()
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("Error: \(error)")
        }.cancelContext
        context.cancel()

        waitForExpectations(timeout: 1)
    }

    /// test that our convenience String constructor applies
    func testCancel3() {
        let dummy = "fred"

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            let data = dummy.data(using: .utf8)!
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: [:])
        }

        let ex = expectation(description: "")
        let rq = URLRequest(url: URL(string: "http://example.com")!)

        let context = cancellable(after(.milliseconds(100))).then {
            cancellable(URLSession.shared.dataTask(.promise, with: rq))
        }.map(String.init).done {
            XCTAssertEqual($0, dummy)
            ex.fulfill()
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("Error: \(error)")
        }.cancelContext
        context.cancel()

        waitForExpectations(timeout: 1)
    }
}

