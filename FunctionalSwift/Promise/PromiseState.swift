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

import Foundation

public enum PromiseState<L, R>: Equatable {
    case pending
    case left(L)
    case right(R)

    var isPending: Bool {
        if case .pending = self {
            return true
        } else {
            return false
        }
    }

    var isRight: Bool {
        if case .right = self {
            return true
        } else {
            return false
        }
    }

    var isLeft: Bool {
        if case .left = self {
            return true
        } else {
            return false
        }
    }

    func map<A>(_ closure: (R) -> A) -> PromiseState<L, A> {
        switch self {
        case let .right(value):
            return .right(closure(value))
        case let .left(error):
            return .left(error)
        case .pending:
            return .pending
        }
    }

    var either: Either<L, R>? {
        switch self {
        case let .right(value):
            return .right(value)
        case let .left(error):
            return .left(error)
        case .pending:
            return nil
        }
    }

    init(_ either: Either<L, R>?) {
        switch either {
        case .left(let left):
            self = .left(left)
        case .right(let right):
            self = .right(right)
        case nil:
            self = .pending
        }
    }
}

public func ==<L, R>(lhs: PromiseState<L, R>, rhs: PromiseState<L, R>) -> Bool {
    switch (lhs, rhs) {
    case (.pending, .pending), (.left, .left), (.right, .right): return true
    default: return false
    }
}
