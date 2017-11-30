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

// MARK: - Dictionary functor

/// An infix synonym for `map(_:)`.
///
/// The name of this operation is allusion to `^`. Note the similarities between their types:
///
///      (^)  : (T -> U)        T  ->     U
///     (<^>) : (T -> U) -> [V: T] -> [V: U]
///
/// __Examples__:
///
/// If you need transform all values of `Dictionary`:
///
///     let jsonToPrice: (JSON) -> Price = ...
///     let data: [Currency: JSON] = ...
///     // paymentMethods is [Currency: Price]
///     let paymentMethods = jsonToPrice <^> data
public func <^><T, U, Key>(_ transform: (T) -> U,
                           _ arg: [Key: T]) -> [Key: U] {
    var newDictionary: [Key: U] = [:]
    arg.forEach { pair in
        newDictionary[pair.0] = transform(pair.1)
    }
    return newDictionary
}

/// Replace all locations in the input with the same value.
/// The default definition is `map { _ in transform }`,
/// but this may be overridden with a more efficient version.
///
/// The name of this operation is allusion in `<^>`.
/// Note the similarities between their types:
///
///     (<^ )  : (     U) -> [V: T] -> [V: U]
///     (<^>)  : (T -> U) -> [V: T] -> [V: U]
///
/// Usually this operator is used for debugging.
///
/// - SeeAlso:
/// `<^>` operator.
public func <^<T, U, V>(_ transform: T, _ arg: [U: V]) -> [U: T] {
    return { _ in transform } <^> arg
}

/// Is flipped version of `<^`
///
/// - SeeAlso:
/// `<^>`, `<^` operators.
public func ^><T, U, V>(_ arg: [T: U], _ transform: V) -> [T: V] {
    return { _ in transform} <^> arg
}
