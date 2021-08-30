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

/// An object that acts as a proxy for a result that is initially unknown.
/// May be resolved with one of two result types.
/// Usually `L` (Left) and `R` (Right) represent failure and success results respectively
public final class Promise<L, R> {

    // MARK: - Handlers

    /// Handler to be called on error
    public typealias LeftHandler = (L) -> Void

    /// Handler to be called on success
    public typealias RightHandler = (R) -> Void

    /// Handler to be called on any result
    public typealias CompletionHandler = (Either<L, R>) -> Void

    private var leftHandlers: [LeftHandler] = []
    private var rightHandlers: [RightHandler] = []
    private var completionHandlers: [CompletionHandler] = []

    // MARK: - Observers

    private let syncQueue = DispatchQueue(label: "ru.yoo.money.FunctionalSwift.Promise.ObserverQueue", attributes: [])

    private var observers: [PromiseObserver<L, R>] = []

    private func addObserver<A>(
        on queue: DispatchQueue,
        promise: Promise<L, A>,
        right body: @escaping (R) -> A?
    ) {
        let observer = PromiseObserver<L, R>(queue: queue) { result in
            result.mapLeft(promise.resolveLeft)
                .map {
                    if let a = body($0) {
                        promise.resolveRight(a)
                    }
                }
        }
        syncQueue.async {
            self.observers.append(observer)
            self.update(state: self.state)

        }
    }

    private func addObserver<A>(
        on queue: DispatchQueue,
        promise: Promise<A, R>,
        left body: @escaping (L) -> A?
    ) {
        let observer = PromiseObserver<L, R>(queue: queue) { result in
            result
                .mapLeft {
                    if let a = body($0) {
                        promise.resolveLeft(a)
                    }
                }
                .map(promise.resolveRight)
        }
        syncQueue.async {
            self.observers.append(observer)
            self.update(state: self.state)
        }
    }

    let key = UUID().uuidString
    let queue: DispatchQueue
    private(set) var state: PromiseState<L, R>

    // MARK: - Initialization

    /// Creates a promise with a given state
    /// - Parameters:
    ///   - queue: Queue to resolve promise on. Default is global system queue with default QoS
    ///   - state: Initial state. Default is `pending`
    public init(
        queue: DispatchQueue = .global(),
        state: PromiseState<L, R> = .pending
    ) {
        self.queue = queue
        self.state = state
    }

    /// Creates a promise that resolves using an asynchronous closure that can either resolve or reject
    public convenience init(
        queue: DispatchQueue = .global(),
        _ body: @escaping (@escaping (Either<L, R>) -> Void) -> Void
    ) {
        self.init(queue: queue, state: .pending)
        dispatch(queue) {
            body(self.resolve)
        }
    }

    /// Creates a promise that resolves using an asynchronous closure that can only resolve
    public convenience init(
        queue: DispatchQueue = .global(),
        _ body: @escaping (@escaping (R) -> Void) -> Void
    ) {
        self.init(queue: queue, state: .pending)
        dispatch(queue) {
            body(self.resolveRight)
        }
    }

    /// Creates a promise with left state
    /// - Parameter error: Value of the state
    public static func left(_ value: L) -> Self {
        Self(state: .left(value))
    }

    /// Creates a promise with right state
    /// - Parameter value: Value of the state
    public static func right(_ value: R) -> Self {
        Self(state: .right(value))
    }

    // MARK: - States

    /// Resolves promise with given result
    /// - Parameter result: Result value
    public func resolve(_ result: Either<L, R>) {
        syncQueue.async {
            guard self.state.isPending else { return }
            self.update(state: PromiseState(result))
        }
    }

    /// Rejects a promise with a given left value
    /// - Parameter value: Result value
    public func resolveLeft(_ value: L) {
        resolve(.left(value))
    }

    /// Rejects a promise with a given right value
    /// - Parameter value: Result value
    public func resolveRight(_ value: R) {
        resolve(.right(value))
    }

    // MARK: - Callbacks

    /// Adds a handler to be called when the promise object is resolved with a value
    @discardableResult
    public func right(_ handler: @escaping RightHandler) -> Self {
        syncQueue.async {
            self.rightHandlers.append(handler)
            self.update(state: self.state)
        }
        return self
    }

    /// Adds a handler to be called when the promise object is rejected with an error
    @discardableResult
    public func left(_ handler: @escaping LeftHandler) -> Self {
        syncQueue.async {
            self.leftHandlers.append(handler)
            self.update(state: self.state)
        }
        return self
    }

    /// Adds a handler to be called when the promise object is either resolved or rejected.
    /// This callback will be called after done or fail handlers
    @discardableResult
    public func always(_ handler: @escaping CompletionHandler) -> Self {
        syncQueue.async {
            self.completionHandlers.append(handler)
            self.update(state: self.state)
        }
        return self
    }

    // MARK: - Helpers

    private func update(state: PromiseState<L, R>?) {
        guard let state = state, let result = state.either else {
            return
        }

        self.state = state
        self.notify(result)
    }

    private func notify(_ result: Either<L, R>) {
        dispatch(queue) {
            result
                .first {
                    self.leftHandlers <*> [$0]
                }
                .second {
                    self.rightHandlers <*> [$0]
                }

            _ = self.completionHandlers <*> [result]
        }

        if observers.isEmpty == false {
            observers.forEach { observer in
                dispatch(observer.queue) {
                    observer.notify(result)
                }
            }

            self.observers = []
        }

        leftHandlers.removeAll()
        rightHandlers.removeAll()
        completionHandlers.removeAll()
    }

    private func dispatch(_ queue: DispatchQueue, closure: @escaping () -> Void) {
        if queue === PromiseQueue.instant {
            closure()
        } else {
            queue.sync(execute: closure)
        }
    }
}

// MARK: - Functor

extension Promise {

    /// Transforms promise's right value into another type
    /// - Parameters:
    ///   - queue: Queue to process transformation on. Default is global system queue with default QoS
    ///   - body: Transformation closure
    /// - Returns: Transfromed promise
    @discardableResult
    public func map<A>(
        on queue: DispatchQueue = .global(),
        _ body: @escaping (R) -> A
    ) -> Promise<L, A> {
        let promise = Promise<L, A>(queue: queue)
        addObserver(on: queue, promise: promise, right: body)
        return promise
    }

    /// Returns a promise with Void as a result type
    /// - Parameter queue: Queue to resolve promise on. Default is global system queue with default QoS
    public func asVoid(on queue: DispatchQueue = .global()) -> Promise<L, Void> {
        return map(on: queue) { _ in return }
    }

    /// Transforms promise's left value into another type
    /// - Parameters:
    ///   - queue: Queue to process transformation on. Default is global system queue with default QoS
    ///   - body: Transformation closure
    /// - Returns: Transfromed promise
    @discardableResult
    public func mapLeft<A>(
        on queue: DispatchQueue = .global(),
        _ body: @escaping (L) -> A
    ) -> Promise<A, R> {
        let promise = Promise<A, R>(queue: queue)
        addObserver(on: queue, promise: promise, left: body)
        return promise
    }
}

/// An infix synonym for `map(_:)`
@discardableResult
public func <^> <L, R, A>(f: @escaping (R) -> A, promise: Promise<L, R>) -> Promise<L, A> {
    return promise.map(f)
}

/// Replace all locations in the input with the same value
@discardableResult
public func <^ <L, R, A>(_ transform: A, _ arg: Promise<L, R>) -> Promise<L, A> {
    return arg.map { _ in transform }
}

/// Flipped version of `<^`
@discardableResult
public func ^> <L, R, A>(_ arg: Promise<L, R>, _ transform: A) -> Promise<L, A> {
    return arg.map { _ in transform }
}

// MARK: - Monad

extension Promise {

    /// Transforms promise's right value into new promise with another right type
    /// - Parameters:
    ///   - queue: Queue to process transformation on. Default is global system queue with default QoS
    ///   - body: Transformation closure
    /// - Returns: Transfromed promise
    @discardableResult
    public func flatMap<A>(
        on queue: DispatchQueue = .global(),
        _ body: @escaping (R) -> Promise<L, A>
    ) -> Promise<L, A> {
        let promise = Promise<L, A>(queue: queue)
        addObserver(on: queue, promise: promise, right: { value -> A? in
            let nextPromise = body(value)
            nextPromise.addObserver(on: queue, promise: promise, right: { value -> A in
                return value
            })

            return nil
        })
        return promise
    }

    /// Transforms promise's left value into new promise with another left type
    /// - Parameters:
    ///   - queue: Queue to process transformation on. Default is global system queue with default QoS
    ///   - body: Transformation closure
    /// - Returns: Transfromed promise
    public func flatMapLeft<A>(
        on queue: DispatchQueue = .global(),
        _ body: @escaping (L) -> Promise<A, R>
    ) -> Promise<A, R> {
        _flatMapLeft(on: queue, body)
    }

    /// Transforms promise's left value into new promise with same type.
    /// May be useful to recover from certain errors
    /// - Parameters:
    ///   - queue: Queue to process transformation on. Default is global system queue with default QoS
    ///   - body: Transformation closure
    /// - Returns: Transfromed promise
    public func flatMapLeft(
        on queue: DispatchQueue = .global(),
        _ body: @escaping (L) -> Promise<L, R>
    ) -> Promise<L, R> {
        _flatMapLeft(on: queue, body)
    }

    private func _flatMapLeft<A>(
        on queue: DispatchQueue = .global(),
        _ body: @escaping (L) -> Promise<A, R>
    ) -> Promise<A, R> {
        let promise = Promise<A, R>(queue: queue)
        addObserver(on: queue, promise: promise, left: { value -> A? in
            let nextPromise = body(value)
            nextPromise.addObserver(on: queue, promise: promise, left: { value -> A? in
                return value
            })
            return nil
        })
        return promise
    }
}

/// An infix synonym for `flatMap(_:)`
@discardableResult
public func >>- <L, R, A>(_ arg: Promise<L, R>,
                          _ transform: @escaping (R) -> Promise<L, A>) -> Promise<L, A> {
    return arg.flatMap(transform)
}

/// Flipped version of `-<<`
@discardableResult
public func -<< <L, R, A>(_ transform: @escaping (R) -> Promise<L, A>,
                          _ arg: Promise<L, R>) -> Promise<L, A> {
    return arg.flatMap(transform)
}
