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

// MARK: - Optional functor

/// An infix synonym for `map(_:)`.
///
/// The name of this operation is allusion to `^`.
/// Note the similarities between their types:
///
///      (^)  : (T -> U)     T  -> U
///     (<^>) : (T -> U) ->  T? -> U?
///
/// __Examples__:
///
/// If you need call function when `Optional` is `some`:
///
///     let data = ... // Give data
///     let image = UIImage.init <^> data
@discardableResult
public func <^><T, U>(_ transform: (T) -> U, _ arg: T?) -> U? {
    return arg.map(transform)
}

/// Replace all locations in the input with the same value.
///
/// The name of this operation is allusion in `<^>`.
/// Note the similarities between their types:
///
///     (<^>)  : (T -> U) -> T? -> U?
///     (<^)   : (     U) -> T? -> U?
///
/// Usually this operator is used for debugging.
///
/// - SeeAlso:
/// `<^>` operator.
public func <^<T, U>(_ transform: T, _ arg: U?) -> T? {
    return arg.map { _ in transform }
}

/// Is flipped version of `<^`
///
/// - SeeAlso:
/// `<^>`, `<^` operators.
public func ^><T, U>(_ arg: T?, _ transform: U) -> U? {
    return arg.map { _ in transform }
}

// MARK: - Optional monad

/// Sequentially compose two actions, passing any value produced by the first
/// as an argument to the second.
///
/// __Example__:
///
///     func imageFromPng(_ data: Data) -> UIImage? {
///         ...
///     }
///
///     task.responseApi { (data: Data?) in
///         let image = data >>- imageFromPng
///         output.didLoadImage <^> image
///     }
public func >>-<T, U>(_ arg: T?, _ transform: (T) -> U?) -> U? {
    return arg.flatMap(transform)
}

/// Same as `>>-`, but with the arguments interchanged.
///
/// __Example__:
///
///     func imageFromPng(_ data: Data) -> UIImage? {
///         ...
///     }
///
///     task.responseApi { (data: Data?) in
///         let image = imageFromPng -<< data
///         output.didLoadImage <^> image
///     }
///
/// - SeeAlso:
/// `>>-` operator.
public func -<<<T, U>(_ transform: (T) -> U?, _ arg: T?) -> U? {
    return arg.flatMap(transform)
}

// MARK: - Optional applicative

/// Sequential application.
///
/// Apply the unwrapped function to the unwrapped argument.
///
/// - Parameters:
///     - transform: Wrapped function.
///     - arg: Wrapped argument.
/// - Returns: `some` if the function and the argument is `some`,
///     otherwise `none`.
public func <*><T, U>(_ transform: Optional<(T) -> U>,
                      arg: Optional<T>) -> Optional<U> {
    switch (transform, arg) {
    case (.some(let transform), .some(let arg)):
        return transform(arg)
    default:
        return nil
    }
}

/// Lift a binary function to actions.
///
/// The function apply function to the unwrapped arguments if both `Optional`
/// is right.
///
/// __Example__:
///
///     let value: NSNumber? = 0.58
///     let text = liftA2(NumberFormatter.localizedString, value, .percent)
///     debugPrint(text) // prints Optional("58 %")
///
/// - Parameters:
///     - transform: The function to be applied to the arguments.
///     - arg1: The first argument.
///     - arg2: The second argument.
/// - Returns: `some` when both arguments are `some`, otherwise `none`.
public func liftA2<T, U, V>(_ transform: (T, U) -> V,
                            _ arg1: Optional<T>,
                            _ arg2: Optional<U>) -> Optional<V> {
    switch (arg1, arg2) {
    case (.some(let arg1), .some(let arg2)):
        return transform(arg1, arg2)
    default:
        return nil
    }
}

/// Lift a ternary function to actions.
///
/// The function apply function to the unwrapped arguments if all `Optional`
/// is `some`.
///
/// - Seealso: `liftA2(_:_:_:)`
/// - Parameters:
///     - transform: The function to be applied to the arguments.
///     - arg1: The first argument.
///     - arg2: The second argument.
///     - arg3: The third argument.
/// - Returns: `some` when all arguments are `some`, otherwise `none`.
public func liftA3<T, U, V, W>(_ transform: (T, U, V) -> W,
                               _ arg1: Optional<T>,
                               _ arg2: Optional<U>,
                               _ arg3: Optional<V>) -> Optional<W> {
    switch (arg1, arg2, arg3) {
    case (.some(let arg1), .some(let arg2), .some(let arg3)):
        return transform(arg1, arg2, arg3)
    default:
        return nil
    }
}
