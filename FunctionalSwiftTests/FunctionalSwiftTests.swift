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

import XCTest
import FunctionalSwift

class FunctionalSwiftTests: XCTestCase {
    
    func testEitherOperationForTheEitherWithLeftElement() {
        let bar: Either<String, Int> = .left("foo")
        let foo = bar.either({ "left \($0)" },
                             { "right \($0)" })
        let expected = "left foo"
        XCTAssertEqual(foo, expected)
    }

    func testEitherOperationForTheEitherWithRightElement() {
        let bar: Either<String, Int> = .right(10)
        let foo = bar.either({ "left \($0)" },
                             { "right \($0)" })
        let expected = "right 10"
        XCTAssertEqual(foo, expected)
    }

    func testIdentity() {
        let a = 5
        let b = "Test"

        XCTAssertEqual(a, id(a))
        XCTAssertEqual(b, id(b))
    }
}
