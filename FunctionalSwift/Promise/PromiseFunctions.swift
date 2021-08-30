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

import Dispatch
import Foundation

enum PromiseQueue {
    static let background = DispatchQueue.global(qos: .background)
    static let instant = DispatchQueue(label: "ru.yoo.money.FunctionalSwift.Promise.InstantQueue")
    static let barrier = DispatchQueue(label: "ru.yoo.money.FunctionalSwift.Promise.BarrierQueue")
    static let async = DispatchQueue(label: "ru.yoo.money.FunctionalSwift.Promise.AsyncQueue", attributes: .concurrent)
}

// swiftlint:disable force_unwrapping

public func zip2<L, R1, R2>(_ p1: Promise<L, R1>, _ p2: Promise<L, R2>) -> Promise<L, (R1, R2)> {
    let promises = [
        p1.asVoid(on: PromiseQueue.instant),
        p2.asVoid(on: PromiseQueue.instant),
    ]
    return zip(promises).map(on: PromiseQueue.instant) { _ in
        (p1.state.either!.right!, p2.state.either!.right!)
    }
}

public func zip3<L, R1, R2, R3>(_ p1: Promise<L, R1>,
                                _ p2: Promise<L, R2>,
                                _ p3: Promise<L, R3>) -> Promise<L, (R1, R2, R3)> {
    let promises = [
        p1.asVoid(on: PromiseQueue.instant),
        p2.asVoid(on: PromiseQueue.instant),
        p3.asVoid(on: PromiseQueue.instant),
    ]
    return zip(promises).map(on: PromiseQueue.instant) { _ in
        (p1.state.either!.right!, p2.state.either!.right!, p3.state.either!.right!)
    }
}

public func zip<L, R>(_ promises: [Promise<L, R>]) -> Promise<L, [R]> {
    let masterPromise = Promise<L, [R]>()
    var (total, resolved) = (promises.count, 0)

    if promises.isEmpty {
        masterPromise.resolveRight([])
    } else {
        promises.forEach { promise in
            _ = promise
                .right { value in
                    PromiseQueue.barrier.sync {
                        resolved += 1
                        if resolved == total {
                            masterPromise.resolveRight(promises.map { $0.state.either!.right! })
                        }
                    }
                }
                .left { error in
                    PromiseQueue.barrier.sync {
                        masterPromise.resolveLeft(error)
                    }
                }
        }
    }

    return masterPromise
}

@discardableResult
public func await<T>(_ promise: Promise<Error, T>) throws -> T {
    var result: T!
    var error: Error?
    let group = DispatchGroup()
    group.enter()
    promise
        .right { t in
            result = t
            group.leave()
        }
        .left { e in
            error = e
            group.leave()
        }
    group.wait()
    if let e = error {
        throw e
    }
    return result
}

@discardableResult
public func async<T>(block: @escaping () throws -> T) -> Promise<Error, T> {
    let promise = Promise<Error, T>()
    PromiseQueue.async.async {
        do {
            promise.resolveRight(try block())
        } catch {
            promise.resolveLeft(error)
        }
    }
    return promise
}

public func after<L, T>(_ interval: DispatchTimeInterval, _ promise: @escaping () -> Promise<L, T>?) -> Promise<L, T> {
    let masterPromise = Promise<L, T>()
    PromiseQueue.async.asyncAfter(deadline: .now() + interval) {
        promise()?.always(masterPromise.resolve)
    }
    return masterPromise
}

// swiftlint:enable force_unwrapping
