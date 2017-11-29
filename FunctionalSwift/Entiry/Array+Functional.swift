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

// MARK: - Array functor

/// An infix synonym for `map(_:)`.
///
/// The name of this operation is allusion to `^`.
/// Note the similarities between their types:
///
///      (^)  : (T -> U)      T  ->  U
///     (<^>) : (T -> U) ->  [T] -> [U]
///
/// __Examples__:
///
/// If you need transform all elements of array:
///
///     let json: [JSON] = ...
///     let bankCards = BankCard.create <^> json // bankCards is [BankCard]
@discardableResult
public func <^><T, U>(_ transform: (T) -> U, _ arg: [T]) -> [U] {
    return arg.map(transform)
}

/// Replace all locations in the input with the same value.
/// The default definition is `map { _ in transform }`,
/// but this may be overridden with a more efficient version.
///
/// The name of this operation is allusion in `<^>`.
/// Note the similarities between their types:
///
///     (<^ )  : (     U) -> [T] -> [U]
///     (<^>)  : (T -> U) -> [T] -> [U]
///
/// Usually this operator is used for debugging.
///
/// - SeeAlso:
/// `<^>` operator.
public func <^<T, U>(_ transform: T, _ arg: [U]) -> [T] {
    return arg.map { _ in transform }
}

/// Is flipped version of `<^`
///
/// - SeeAlso:
/// `<^>`, `<^` operators.
public func ^><T, U>(_ arg: [T], _ transform: U) -> [U] {
    return arg.map { _ in transform }
}

// MARK: - Array monad

/// Sequentially compose two actions, passing any value produced by the first
/// as an argument to the second.
///
/// __Example__:
///
///     let packageToOperation: (Package) -> [Operation]
///
///     let packages: [Package] = ...
///     // operations is [Operation]
///     let operations = packages >>- packageToOperation
public func >>-<T, U>(_ arg: [T], _ transform: (T) -> [U]) -> [U] {
    return arg.flatMap(transform)
}

/// Same as `>>-`, but with the arguments interchanged.
///
/// __Example__:
///
///     let packageToOperation: (Package) -> [Operation]
///
///     let packages: [Package] = ...
///     // operations is [Operation]
///     let operations = packageToOperation -<< packages
///
/// - SeeAlso:
/// `>>-` operator.
public func -<<<T, U>(_ transform: (T) -> [U], _ arg: [T]) -> [U] {
    return arg.flatMap(transform)
}

// MARK: - Array applicative

/// Sequential application.
///
/// Apply all functions to the all values.
///
/// __Example__:
///
///     let parsers: [(JSON) -> Operation?] = ...
///     let data: [JSON] = ...
///     // operations is [Operation?]
///     let opetations = parsers <*> json
///     // cleanOperations is [Operation]
///     let cleanOperations = operations.flatMap { $0 }
///
/// - Parameters:
///     - transform: Array of functions.
///     - arg: Array of arguments.
/// - Returns: array of applying all functions to all argumaents.
public func <*><T, U>(_ transform: [(T) -> U], arg: [T]) -> [U] {
    return transform.flatMap { arg.map($0) }
}

/// Lift a binary function to actions.
///
/// The function apply function to all arguments.
///
/// - Parameters:
///     - transform: The function to be applied to the arguments.
///     - arg1: The first argument.
///     - arg2: The second argument.
/// - Returns: Array of applying function to arguments.
public func liftA2<T, U, V>(_ transform: (T, U) -> V,
                            _ arg1: [T],
                            _ arg2: [U]) -> [V] {
    return arg1.flatMap { arg1 in arg2.map { transform(arg1, $0) } }
}

/// Lift a ternary function to actions.
///
/// The function apply function to all arguments.
///
/// - Parameters:
///     - transform: The function to be applied to the arguments.
///     - arg1: The first argument.
///     - arg2: The second argument.
///     - arg3: The third argument.
/// - Returns: Array of applying function to arguments.
public func liftA3<T, U, V, W>(_ transform: (T, U, V) -> W,
                               _ arg1: [T],
                               _ arg2: [U],
                               _ arg3: [V]) -> [W] {
    return arg1.flatMap { arg1 in
        arg2.flatMap { arg2 in
            arg3.map {
                transform(arg1, arg2, $0)
            }
        }
    }
}
