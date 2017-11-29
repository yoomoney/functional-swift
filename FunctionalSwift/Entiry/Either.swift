/* The MIT License
 *
 * Copyright (c) 2007—2017 NBCO Yandex.Money LLC
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

/// The `Either` type represents values with two possibilities: a value of type `Either<A, B>` is either `left(a)` or
/// `right(b)`.
///
/// The `Either` type is sometimes used to represent a value which is either correct or an error; by convention,
/// the `left` constructor is used to hold an error value and the `right` constructor is used to hold a correct
/// value (mnemonic: "right" also means "correct").
///
/// __Examples__:
///
/// The type `Either<String, Int>` is the type of values which can be either a `String` or an `Int`. The `left`
/// constructor can be used only on `String`s, and the `right` constructor can be used only on `Int`s:
///
///     >>> let s: Either<String, Int> = .left("foo")
///     >>> s
///     s: Either<String, Int> = left {
///         left = "foo"
///     }
///     >>> let n: Either<String, Int> = .right(3)
///     >>> n
///     n: Either<String, Int> = right {
///         right = 3
///     }
///     >>> type(of: s)
///     Either<String, Int>.Type = Either<String, Int>
///     >>> type(of: n)
///     Either<String, Int>.Type = Either<String, Int>
///
/// The `map(_:)` from our `Functor` instance will ignore `left` values, but will apply the supplied function to values
/// contained in a `right`:
///
///     >>> let s: Either<String, Int> = .left("foo")
///     >>> let n: Either<String, Int> = .right(3)
///     >>> s.map { $0 * 2 }
///     Either<String, Int> = left {
///         left = "foo"
///     }
///     >>> n.map { $0 * 2 }
///     Either<String, Int> = right {
///         right = 6
///     }
public enum Either<L, R> {
    /// Left value of `Either`.
    ///
    /// If `Either` used as result of an operation this contains error.
    case left(L)
    /// Right value of `Either`.
    ///
    /// If `Either` used as result of an operation this contains success value.
    case right(R)
}

// MARK: - Swift functor

extension Either {
    /// Evaluates the given closure when this `Either` instance is `right`,
    /// passing the unwrapped value as a parameter.
    ///
    /// Use the `map(_:)` method with a closure that returns a non-either value.
    /// This example performs an arithmetic operation on an
    /// either integer.
    ///
    ///     >>> func stringToInt(_ string: String) -> Either<String, Int> {
    ///     >>>     switch Int(string) {
    ///     >>>     case let .some(int):
    ///     >>>         return .right(int)
    ///     >>>     case .none:
    ///     >>>         return .left("Not an integer")
    ///     >>>     }
    ///     >>> }
    ///     >>> let possibleNumber = stringToInt("42")
    ///     >>> let possibleSquare = possibleNumber.map { $0 * $0 }
    ///     >>> possibleSquare
    ///     Either<String, Int> = right {
    ///         right = 1764
    ///     }
    ///
    ///     >>> let noNumber: Int? = stringToInt("test")
    ///     >>> let noSquare = noNumber.map { $0 * $0 }
    ///     >>> noSquare
    ///     Either<String, Int> = left {
    ///         left = "Not an integer"
    ///     }
    ///
    /// - Parameter transform: A closure that takes the unwrapped value
    ///   of the instance.
    /// - Returns: The result of the given closure. If this instance is `left`,
    ///   returns `left`.
    @discardableResult
    public func map<T>(_ transform: (R) -> T) -> Either<L, T> {
        switch self {
        case let .right(right):
            return .right(transform(right))
        case let .left(left):
            return .left(left)
        }
    }
}

// MARK: - Swift monad

extension Either {
    /// Evaluates the given closure when this `Either` instance is not `left`,
    /// passing the unwrapped value as a parameter.
    ///
    /// Use the `flatMap(_:)` method with a closure that returns an either value.
    /// This example performs an arithmetic operation with an either result on
    /// an either integer.
    ///
    ///     >>> let possibleNumber: Either<String, Int> = stringToInt("42")
    ///     >>> let nonOverflowingSquare = possibleNumber.flatMap { x -> Either<String, Int> in
    ///     >>>    let (result, overflowed) = x.multipliedReportingOverflow(by: x)
    ///     >>>    return overflowed == .overflow ? "Square overflow integer capacity" : result
    ///     >>> }
    ///     >>> nonOverflowingSquare
    ///     Either<String, Int> = right {
    ///         right = 1764
    ///     }
    ///
    ///     >>> let noNumber: Int? = stringToInt("test")
    ///     >>> let nonOverflowingSquare = possibleNumber.flatMap { x -> Either<String, Int> in
    ///     >>>    let (result, overflowed) = x.multipliedReportingOverflow(by: x)
    ///     >>>    return overflowed == .overflow ? "Square overflow integer capacity" : result
    ///     >>> }
    ///     >>> nonOverflowingSquare
    ///     Either<String, Int> = left {
    ///         left = "Not an integer"
    ///     }
    ///
    ///     >>> let possibleNumber: Either<String, Int> = stringToInt("1234567890123")
    ///     >>> let nonOverflowingSquare = possibleNumber.flatMap { x -> Either<String, Int> in
    ///     >>>    let (result, overflowed) = x.multipliedReportingOverflow(by: x)
    ///     >>>    return overflowed == .overflow ? "Square overflow integer capacity" : result
    ///     >>> }
    ///     >>> nonOverflowingSquare
    ///     Either<String, Int> = left {
    ///         left = "Square overflow integer capacity"
    ///     }
    ///
    /// - Parameter transform: A closure that takes the unwrapped value
    ///   of the instance.
    /// - Returns: The result of the given closure. If this instance is `left`,
    ///   returns `left`.
    @discardableResult
    public func flatMap<T>(_ transform: (R) -> Either<L, T>) -> Either<L, T> {
        switch self {
        case let .right(right):
            return transform(right)
        case let .left(left):
            return .left(left)
        }
    }
}

// MARK: - Swift bifunctor

extension Either {
    /// Evaluates the given closure when this `Either` instance is `left`,
    /// passing the unwrapped value as a parameter.
    ///
    /// Use the `second(_:)` method for evaluates when this `Either` is `right`.
    ///
    /// - SeeAlso:
    /// `map(_:)`, `second(_:)` methods.
    ///
    /// - Parameter transform: A closure that takes the unwrapped value
    ///   of the instance.
    /// - Returns: The result of the given closure. If this instance is `right`,
    ///   returns `right`.
    @discardableResult
    public func first<T>(_ transform: (L) -> T) -> Either<T, R> {
        switch self {
        case let .right(right):
            return .right(right)
        case let .left(left):
            return .left(transform(left))
        }
    }

    /// Evaluates the given closure when this `Either` instance is `right`,
    /// passing the unwrapped value as a parameter.
    ///
    /// This is a synonym for the `map(_:)` method.
    ///
    /// Use the `first(_:)` method for evaluates when this `Either` is `left`.
    ///
    /// - SeeAlso:
    /// `map(_:)`, `first(_:)` methods.
    ///
    /// - Parameter transform: A closure that takes the unwrapped value
    ///   of the instance.
    /// - Returns: The result of the given closure. If this instance is `left`,
    ///   returns `left`.
    @discardableResult
    public func second<T>(_ f: (R) -> T) -> Either<L, T> {
        return map(f)
    }

    /// Evaluates the first given closure when this `Either` instance is `left`,
    /// and second given closure when this `Either` is `right`
    ///
    /// Applying this method to Bifunctor is equivalent to applying `first(_:)`
    /// and `second(_:)` methods sequentially.
    ///
    /// - SeeAlso:
    /// `first(_:)`, `second(_:)` methods.
    ///
    /// - Parameter f: A closure that takes the unwrapped value
    ///   of the first.
    /// - Parameter s: A closure that takes the unwrapped value
    ///   of the second.
    /// - Returns: The result of the given closure.
    @discardableResult
    public func bimap<T, Z>(_ f: (L) -> T, _ s: (R) -> Z) -> Either<T, Z> {
        return first(f).second(s)
    }
}

extension Either {
    /// Evaluates the given closure when this `Either` instance is `left`,
    /// passing the unwrapped value as a parameter.
    ///
    /// This is a synonym for the `first(_:)` method.
    ///
    /// Use the `second(_:)` method for evaluates when this `Either` is `right`.
    ///
    /// - SeeAlso:
    /// `first(_:)` method.
    ///
    /// - Parameter transform: A closure that takes the unwrapped value
    ///     of the instance.
    /// - Returns: The result of the given closure. If this instance is `right`,
    ///     returns `right`.
    @discardableResult
    public func mapLeft<T>(_ transform: (L) -> T) -> Either<T, R> {
        return first(transform)
    }
}

// MARK: - Either functor

/// An infix synonym for `map(_:)`.
///
/// The name of this operation is allusion to `^`. Note the similarities between their types:
///
///      (^)  : (T -> U)              T  ->           U
///     (<^>) : (T -> U) -> Either<V, T> -> Either<V, U>
///
/// __Examples__:
///
/// If you need call function when `Either` is `right` (e.g when you have `Either<Error, T>`):
///
///
///     task.responseApi(UIImage.Type) { image in
///         output.avatarWasLoaded <^> image
///     }
@discardableResult
public func <^><T, L, U>(_ transform: (T) -> U, _ arg: Either<L, T>) -> Either<L, U> {
    return arg.map(transform)
}

/// Replace all locations in the input with the same value. The default definition is `map { _ in transform }`,
/// but this may be overridden with a more efficient version.
///
/// The name of this operation is allusion in `<^>`. Note the similarities between their types:
///
///     (<^ )   : (     U) -> Either<V, T> -> Either<V, U>
///     (<^>)   : (T -> U) -> Either<V, T> -> Either<V, U>
///
/// Usually this operator is used for debugging.
///
/// - SeeAlso:
/// `<^>` operator.
public func <^<T, U, V>(_ transform: T, _ arg: Either<U, V>) -> Either<U, T> {
    return arg.map { _ in transform }
}

/// Is flipped version of `<^`
///
/// - SeeAlso:
/// `<^>`, `<^` operators.
public func ^><T, U, V>(_ arg: Either<T, U>, _ transform: V) -> Either<T, V> {
    return arg.map { _ in transform }
}

// MARK: - Either monad

/// Sequentially compose two actions, passing any value produced by the first as an argument to the second.
///
/// __Example__:
///
///     func imageFromPng(_ data: Data) -> Result<UIImage> {
///         ...
///     }
///
///     task.responseApi { (data: Result<Data>) in
///         let image = data >>- imageFromPng
///         image.first(output.didLoadImage)
///             .second(output.didFailLoadImage)
///     }
public func >>-<T, U, V>(_ arg: Either<T, U>, _ transform: (U) -> Either<T, V>) -> Either<T, V> {
    return arg.flatMap(transform)
}

/// Same as `>>-`, but with the arguments interchanged.
///
/// - SeeAlso:
/// `>>-` operator.
public func -<<<T, U, V>(_ transform: (T) -> Either<U, V>, _ arg: Either<U, T>) -> Either<U, V> {
    return arg.flatMap(transform)
}

// MARK: - Either applicative

/// Sequential application.
///
/// Apply the unwrapped function to the unwrapped argument.
///
/// - Parameters:
///     - transform: Wrapped function.
///     - arg: Wrapped argument.
/// - Returns: `rigth` if the function and the argument is right, otherwise `left`.
public func <*><T, U, V>(_ transform: Either<T, (U) -> V>, arg: Either<T, U>) -> Either<T, V> {
    switch transform {
    case let .right(transform):
        switch arg {
        case let .right(arg):
            return .right(transform(arg))
        case let .left(left):
            return .left(left)
        }
    case let .left(left):
        return .left(left)
    }
}

/// Lift a binary function to actions.
///
/// The function apply function to the unwrapped arguments if both Either is right.
///
/// - Parameters:
///     - transform: The function to be applied to the arguments.
///     - arg1: The first argument.
///     - arg2: The second argument.
/// - Returns: `right` when both arguments are `right`, otherwise left.
public func liftA2<T, U, V, W>(_ transform: (T, U) -> V,
                               _ arg1: Either<W, T>,
                               _ arg2: Either<W, U>) -> Either<W, V> {
    switch (arg1, arg2) {
    case (.right(let arg1), .right(let arg2)):
        return .right(transform(arg1, arg2))
    case (.left(let left1), _):
        return .left(left1)
    case (_, .left(let left2)):
        return .left(left2)
    default:
        fatalError()
    }
}

/// Lift a ternary function to actions.
///
/// The function apply function to the unwrapped arguments if all `Either` is `right`.
/// - Parameters:
///     - transform: The function to be applied to the arguments.
///     - arg1: The first argument.
///     - arg2: The second argument.
///     - arg3: The third argument.
/// - Returns: `right` when all arguments are `right`, otherwise `left`.
public func liftA3<T, U, V, W, X>(_ transform: (T, U, V) -> W,
                                  _ arg1: Either<X, T>,
                                  _ arg2: Either<X, U>,
                                  _ arg3: Either<X, V>) -> Either<X, W> {
    switch (arg1, arg2, arg3) {
    case (.right(let arg1), .right(let arg2), .right(let arg3)):
        return .right(transform(arg1, arg2, arg3))
    case (.left(let left1), _, _):
        return .left(left1)
    case (_, .left(let left2), _):
        return .left(left2)
    case (_, _, .left(let left3)):
        return .left(left3)
    default:
        fatalError()
    }
}

// MARK: - Converting to and from simple values

extension Either {
    /// Returns value if the `Either` instance is `left` or `nil` if it is `right`
    public var left: L? {
        switch self {
        case .left(let left): return left
        case .right: return nil
        }
    }

    /// Returns value if the `Either` instance is `right` or `nil` if it is `left`
    public var right: R? {
        switch self {
        case .left: return nil
        case .right(let right): return right
        }
    }
}

// MARK: - The Either associated operations.

extension Either {

    /// Case analysis for the Either type.
    ///
    /// If the value is `left`, apply the first function to `left`; if it is `right`,
    /// apply the second function to `right`.
    ///
    /// - Parameters:
    ///   - f: The first function.
    ///   - s: The second function.
    /// - Returns: The result of the first or second function.
    public func either<T>(_ f: (L) -> T, _ s: (R) -> T) -> T {
        switch self {
        case let .right(right):
            return s(right)
        case let .left(left):
            return f(left)
        }
    }
}
