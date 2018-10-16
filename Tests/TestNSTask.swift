import PMKFoundation
import Foundation
import PromiseKit
import XCTest

#if os(macOS)

class NSTaskTests: XCTestCase {
    func test1() {
        let ex = expectation(description: "")
        let task = Process()
        task.launchPath = "/usr/bin/basename"
        task.arguments = ["/foo/doe/bar"]
        task.launch(.promise).done { stdout, _ in
            let stdout = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
            XCTAssertEqual(stdout, "bar\n")
            ex.fulfill()
        }
        waitForExpectations(timeout: 10)
    }

    func test2() {
        let ex = expectation(description: "")
        let dir = "PMKAbsentDirectory"

        let task = Process()
        task.launchPath = "/bin/ls"
        task.arguments = [dir]

        task.launch(.promise).done { _ in
            XCTFail()
        }.catch { err in
            do {
                throw err
            } catch Process.PMKError.execution(let proc) {
                let expectedStderrData = "ls: \(dir): No such file or directory\n".data(using: .utf8, allowLossyConversion: false)!
                let stdout = (proc.standardOutput as! Pipe).fileHandleForReading.readDataToEndOfFile()
                let stderr = (proc.standardError as! Pipe).fileHandleForReading.readDataToEndOfFile()

                XCTAssertEqual(stderr, expectedStderrData)
                XCTAssertEqual(proc.terminationStatus, 1)
                XCTAssertEqual(stdout.count, 0)
            } catch {
                XCTFail()
            }
            ex.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}

//////////////////////////////////////////////////////////// Cancellation

extension NSTaskTests {
    func testCancel1() {
        let ex = expectation(description: "")
        let task = Process()
        task.launchPath = "/usr/bin/man"
        task.arguments = ["ls"]
        
        let context = cancellable(task.launch(.promise)).done { stdout, _ in
            let stdout = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
            XCTAssertEqual(stdout, "bar\n")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("Error: \(error)")
        }.cancelContext
        context.cancel()
        waitForExpectations(timeout: 3)
    }

    func testCancel2() {
        let ex = expectation(description: "")
        let dir = "/usr/bin"

        let task = Process()
        task.launchPath = "/bin/ls"
        task.arguments = ["-l", dir]

        let context = cancellable(task.launch(.promise)).done { _ in
            XCTFail("failed to cancel process")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("unexpected error \(error)")
        }.cancelContext
        context.cancel()
        waitForExpectations(timeout: 3)
    }
}

#endif
