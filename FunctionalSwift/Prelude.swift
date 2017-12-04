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

/// Identity function.
///
/// - Seealso: [Identity function]
/// (https://en.wikipedia.org/wiki/Identity_function)
public func id<T>(_ identity: T) -> T {
    return identity
}

/// `const(x)` is a unary function which evaluates to `x` for all inputs.
public func const<T, V>( _ const: T) -> (V) -> T {
    return { _ in const }
}

/// Function composition.
///
/// - Seealso: [Function composition]
/// (https://en.wikipedia.org/wiki/Function_composition)
public func • <A, B, C>(lhs: @escaping (B) -> C,
                        rhs: @escaping (A) -> B) -> (A) -> C {
    return { lhs(rhs($0)) }
}

/// Application operator. This operator is redundant, since ordinary
/// application `f(x)` means the same as `f <| x`. However, `<|` has low,
/// right-associative binding precedence, so it sometimes allows parentheses to
/// be omitted; for example:
///
///     f <| g <| h(x) = f(g(h(x)))
///
/// It is also useful in higher-order situations, such as zipWith(<|, fs, xs).
public func <| <A, B>(lhs: (A) -> B, rhs: A) -> B {
    return lhs(rhs)
}

/// Application operator. This operator is redundant, since ordinary
/// application `f(x)` means the same as `x |> f`. However, `|>` has low,
/// left-associative binding precedence, so it sometimes allows parentheses to
/// be omitted; for example:
///
///     h(x) |> g |> f = f(g(h(x)))
///
/// It is also useful in higher-order situations, such as zipWith(|>, fs, xs).
public func |> <A, B>(lhs: A, rhs: (A) -> B) -> B {
    return rhs(lhs)
}
