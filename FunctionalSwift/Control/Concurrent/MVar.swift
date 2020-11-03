/* The MIT License
 *
 * Copyright © 2020 NBCO YooMoney LLC
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

import Darwin

// swiftlint:disable force_unwrapping

/// An `MVar` (pronounced "em-var") is a synchronising variable, used for communication between concurrent threads.
/// It can be thought of as a box, which may be empty or full.
///
/// An `MVar<A>` is mutable location that is either empty or contains a value of type `A`. It has two fundamental
/// operations: `put(_:)` which fills an `MVar` if it is empty and blocks otherwise, and `take()` which empties
/// an `MVar` if it is full and blocks otherwise. They can be used in multiple different ways:
/// 1. As synchronized mutable variables,
/// 2. As channels, with `take()` and `put(_:)` as receive and send, and
/// 3. As a binary semaphore `MVar<Void>`, with `take()` and `put(_:)` as wait and signal.
public final class MVar<A> {
    private var value: A?
    private var lock = pthread_mutex_t()
    private var takeCond = pthread_cond_t()
    private var putCond = pthread_cond_t()

    /// Create an `MVar` which is initially empty.
    public init() {
        pthread_mutex_init(&lock, nil)
        pthread_cond_init(&takeCond, nil)
        pthread_cond_init(&putCond, nil)
    }

    /// Create an `MVar` which contains the supplied value.
    ///
    /// - Parameter value: initial value
    public convenience init(value: A) {
        self.init()
        self.put(value)
    }

    /// Return the contents of the `MVar`. If the `MVar` is currently empty, `take()` will wait until it is full. After
    /// a `take()`, the `MVar` is left empty.
    ///
    /// - Returns: the contents of the `MVar`
    /// - SeeAlso: `read()`
    ///
    /// There are two further important properties of `take()`:
    ///
    /// - `take()` is single-wakeup. That is, if there are multiple threads blocked in `take()`, and the `MVar` becomes
    /// full, only one thread will be woken up. The runtime guarantees that the woken thread completes its `take()`
    /// operation.
    /// - When multiple threads are blocked on an `MVar`, they are woken up in FIFO order. This is useful for providing
    /// fairness properties of abstractions built using `MVar`s.
    public func take() -> A {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        while self.value == nil {
            pthread_cond_wait(&takeCond, &lock)
        }
        let value = self.value!
        self.value = nil
        pthread_cond_signal(&putCond)
        return value
    }

    /// Put a value into an `MVar`. If the `MVar` is currently full, `put(_:)` will wait until it becomes empty.
    ///
    /// - Parameter value: new value
    ///
    /// There are two further important properties of `put(_:)`:
    ///
    /// - `put(_:)` is single-wakeup. That is, if there are multiple threads blocked in `put(_:)`, and the `MVar`
    /// becomes empty, only one thread will be woken up. The runtime guarantees that the woken thread completes
    /// its `put(_:)` operation.
    /// - When multiple threads are blocked on an `MVar`, they are woken up in FIFO order. This is useful for
    /// providing fairness properties of abstractions built using `MVar`s.
    public func put(_ value: A) {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        while self.value != nil {
            pthread_cond_wait(&putCond, &lock)
        }
        self.value = value
        pthread_cond_signal(&takeCond)
    }

    /// Atomically read the contents of an `MVar`. If the `MVar` is currently empty, `read()` will wait until it is
    /// full. `read()` is guaranteed to receive the next `put(_:)`.
    ///
    /// - Returns: the contents of the `MVar`
    /// - SeeAlso: `take()`
    ///
    /// `read()` is multiple-wakeup, so when multiple readers are blocked on an `MVar`, all of them are woken up at
    /// the same time.
    public func read() -> A {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        while self.value == nil {
            pthread_cond_wait(&takeCond, &lock)
        }
        let value = self.value!
        pthread_cond_signal(&putCond)
        return value
    }

    /// Take a value from an `MVar`, put a new value into the `MVar` and return the value taken. This function is
    /// atomic only if there are no other producers for this `MVar`.
    ///
    /// - Parameter value: new value
    /// - Returns: old value
    public func swap(_ value: A) -> A {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        while self.value == nil {
            pthread_cond_wait(&takeCond, &lock)
        }
        let old = self.value!
        self.value = value
        return old
    }

    /// A non-blocking version of `take()`. The `tryTake()` function returns immediately. After `tryTake()`,
    /// the `MVar` is left empty.
    ///
    /// + Returns: `.none` if the `MVar` is empty, or `.some(a)` if the `MVar` was full with contents `a`.
    /// + SeeAlso: `take()`
    public func tryTake() -> A? {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        guard self.value != nil else { return nil }
        let value = self.value!
        self.value = nil
        pthread_cond_signal(&putCond)
        return value
    }

    /// A non-blocking version of `put(_:)`. The `tryPut(_:)` function attempts to put the value `a` into the `MVar`.
    ///
    /// + Returns: `true` if it was putted successful, or `false` otherwise.
    /// + SeeAlso: `put(_:)`
    public func tryPut(_ value: A) -> Bool {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        guard self.value == nil else { return false }
        self.value = value
        pthread_cond_signal(&takeCond)
        return true
    }

    /// Check whether a given `MVar` is empty.
    ///
    /// + Note: Notice that the boolean value returned is just a snapshot of the state of the `MVar`. By the time you
    /// get to react on its result, the `MVar` may have been filled (or emptied) - so be extremely careful when
    /// using this operation. Use `tryTake(_:)` instead if possible.
    public var isEmpty: Bool {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        return value == nil
    }

    /// `with(_:)` is an rethrows wrapper for operating on the contents of an `MVar`. This operation rethrow exception
    /// if `f` raise exception. It won't replace the original contents of the `MVar` if an exception is raised. However,
    /// it is only atomic if there are no other producers for this `MVar`.
    ///
    /// + Parameter f: `ƒ`
    /// + Returns: calculated `ƒ(a)`
    /// + Seealso: `modify_(_:)` and `modify(_:)`
    public func with<B>(_ f: (A) throws -> B) rethrows -> B {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        while self.value == nil {
            pthread_cond_wait(&takeCond, &lock)
        }
        let value = self.value!
        return try f(value)
    }

    /// A rethrow wrapper for modifying the contents of an `MVar`. Like `with(_:)`, `modify_(_:)` won't replace
    /// the original contents of the `MVar` if an exception is raised during the operation. This function is only
    /// atomic if there are no other producers for this `MVar`.
    ///
    /// + Parameter f: `f`
    /// + SeeAlso: `with(_:)` and `modify(_:)`
    public func modify_(_ f: (A) throws -> A) rethrows {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        while self.value == nil {
            pthread_cond_wait(&takeCond, &lock)
        }
        self.value = try f(self.value!)
    }

    /// A slight variation on `modify_(_:)` that allows a value to be returned (b) in addition to the modified value
    /// of the `MVar`.
    ///
    /// + Parameter f: `ƒ`
    /// + Returns: `ƒ(a).1`
    /// + SeeAlso: `with(_:)` and `modify_(_:)`
    public func modify<B>(_ f: (A) throws -> (A, B)) rethrows -> B {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        while self.value == nil {
            pthread_cond_wait(&takeCond, &lock)
        }
        let a: A
        let b: B
        (a, b) = try f(self.value!)
        self.value = a
        return b
    }

    /// A non-blocking version of `read()`. The `tryRead()` function returns immediately, with `.none` if the `MVar`
    /// was empty, or `.some(a)` if the `MVar` was full with contents `a`.
    ///
    /// + Returns: `.none` if the `MVar` is empty, or `.some(a)` if the `MVar` was full with contents `a`.
    /// + SeeAlso: `read(_:)`
    public func tryRead() -> A? {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }
        guard self.value != nil else { return nil }
        let value = self.value!
        pthread_cond_signal(&putCond)
        return value
    }
}

// swiftlint:enable force_unwrapping
