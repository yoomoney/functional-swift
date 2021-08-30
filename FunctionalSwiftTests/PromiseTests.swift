/* The MIT License
 *
 * Copyright © 2021 NBCO YooMoney LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import FunctionalSwift
import XCTest

final class PromiseTests: XCTestCase {
    func testRightResolvedPromise() {
        let promise: Promise<String, Int> = Promise()
        DispatchQueue.global().async {
            promise.resolveRight(7)
        }
        testPromiseResolve(promise) { result in
            self.xctAssertEqual(result, .right(7))
        }
    }

    func testLeftResolvedPromise() {
        let promise: Promise<String, Int> = Promise()
        DispatchQueue.global().async {
            promise.resolveLeft("test")
        }
        testPromiseResolve(promise) { result in
            self.xctAssertEqual(result, .left("test"))
        }
    }

    func testRightPromiseInit() {
        let promise: Promise<String, Int> = Promise(state: .right(7))
        testPromiseResolve(promise) { result in
            self.xctAssertEqual(result, .right(7))
        }
    }

    func testLeftPromiseInit() {
        let promise: Promise<String, Int> = Promise(state: .left("test"))
        testPromiseResolve(promise) { result in
            self.xctAssertEqual(result, .left("test"))
        }
    }

    func testCancelingPromise() {
        let promise: Promise<Error, Int> = .canceling
        testPromiseResolve(promise) { result in
            switch result {
            case .left(PromiseError.cancel): break
            case .left: XCTFail("Wrong error")
            case .right: XCTFail("Wrong result")
            }
        }
    }

    func testPromiseMap() {
        let promise: Promise<String, Int> = Promise(state: .right(7))
        testPromiseResolve(
            promise.map { "\($0)" }
        ) { result in
            self.xctAssertEqual(result, .right("7"))
        }
    }

    func testPromiseFlatMap() {
        let promise: Promise<Error, Int> = Promise(state: .right(7))
        let transformedPromise: Promise<Error, String> = promise.flatMap { value in
            XCTAssertEqual(value, 7, "Wrong value")
            return .canceling
        }
        testPromiseResolve(transformedPromise) { result in
            switch result {
            case .left(PromiseError.cancel): break
            case .left: XCTFail("Wrong error")
            case .right: XCTFail("Wrong result")
            }
        }
    }

    // MARK: - Helpers

    private func testPromiseResolve<L, R>(
        _ promise: Promise<L, R>,
        timeout: TimeInterval = 1,
        testResult: @escaping (Either<L, R>) -> Void
    ) {
        let promiseResolved = expectation(description: "Promise resolved")
        promise.always { result in
            promiseResolved.fulfill()
            testResult(result)
        }
        let result = XCTWaiter.wait(for: [promiseResolved], timeout: timeout)
        XCTAssertNotEqual(result, .timedOut, "Promise was not resolved")
    }

    private func xctAssertEqual<L: Equatable, R: Equatable>(_ lhs: Either<L, R>, _ rhs: Either<L, R>) {
        switch (lhs, rhs) {
        case (.left(let lhs), .left(let rhs)):
            XCTAssertEqual(lhs, rhs, "Wrong result")
        case (.right(let lhs), .right(let rhs)):
            XCTAssertEqual(lhs, rhs, "Wrong result")
        default:
            XCTFail("Wrong result")
        }
    }
}
