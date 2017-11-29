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

/// The protocol of monoids (types with an associative binary operation that has an identity).
///
/// Instances should satisfy the following laws:
///
///     x.mappend(.mempty) = x
///     T.mempty.mappend(x) = x
///     x.mappend(y.mappend(z)) = x.mappend(y).mappend(z)
///     [x, y, z].mconcat() = [x, y, z].reduce(T.mempty, { $0.mappend($1) }
///
/// - SeeAlso:
/// [Associative binary function](https://en.wikipedia.org/wiki/Associative_property)
public protocol Monoid {
    /// Identity of `mappend(_:)`.
    static var mempty: Self { get }

    /// An associative operation.
    func mappend(_ monoid: Self) -> Self
}

public extension Sequence where Iterator.Element: Monoid {
    /// Fold a sequence using monoid.
    ///
    /// For most types, the default definition for `mconcat()` will be used,
    /// but the function must be an optimized version for specific types.
    ///
    /// - Returns: Element combined with `mappend(_:)` function.
    public func mconcat() -> Iterator.Element {
        return reduce(Iterator.Element.mempty) { $0.mappend($1) }
    }
}
