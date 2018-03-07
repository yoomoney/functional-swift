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

import FunctionalSwift
import XCTest

class CollectionSplitTests: XCTestCase {

    let emptyData: [Int] = []
    let data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

    func testSplitOn() {
        XCTAssert(data.split(on: 5).elementsEqual([[1, 2, 3, 4], [6, 7, 8, 9, 0]], by: ==))
    }

    func testSplitOneOf() {
        XCTAssert(data.split(oneOf: [5, 9]).elementsEqual([[1, 2, 3, 4], [6, 7, 8], [0]], by: ==))

    }

    func testChunksOf() {
        XCTAssert(emptyData.chunks(of: 5).elementsEqual([], by: ==))
        XCTAssert(data.chunks(of: -5).elementsEqual([], by: ==))

        XCTAssert(data.chunks(of: 1).elementsEqual([[1], [2], [3], [4], [5], [6], [7], [8], [9], [0]], by: ==))
        XCTAssert(data.chunks(of: 2).elementsEqual([[1, 2], [3, 4], [5, 6], [7, 8], [9, 0]], by: ==))
        XCTAssert(data.chunks(of: 3).elementsEqual([[1, 2, 3], [4, 5, 6], [7, 8, 9], [0]], by: ==))
        XCTAssert(data.chunks(of: 4).elementsEqual([[1, 2, 3, 4], [5, 6, 7, 8], [9, 0]], by: ==))
        XCTAssert(data.chunks(of: 5).elementsEqual([[1, 2, 3, 4, 5], [6, 7, 8, 9, 0]], by: ==))
        XCTAssert(data.chunks(of: 6).elementsEqual([[1, 2, 3, 4, 5, 6], [7, 8, 9, 0]], by: ==))
        XCTAssert(data.chunks(of: 7).elementsEqual([[1, 2, 3, 4, 5, 6, 7], [8, 9, 0]], by: ==))
        XCTAssert(data.chunks(of: 8).elementsEqual([[1, 2, 3, 4, 5, 6, 7, 8], [9, 0]], by: ==))
        XCTAssert(data.chunks(of: 9).elementsEqual([[1, 2, 3, 4, 5, 6, 7, 8, 9], [0]], by: ==))
        XCTAssert(data.chunks(of: 10).elementsEqual([[1, 2, 3, 4, 5, 6, 7, 8, 9, 0]], by: ==))
        XCTAssert(data.chunks(of: 11).elementsEqual([[1, 2, 3, 4, 5, 6, 7, 8, 9, 0]], by: ==))
    }
    
    func testSplitPlaces() {
        XCTAssert(emptyData.splitPlaces([5]).elementsEqual([], by: ==))
        XCTAssert(data.splitPlaces([-5]).elementsEqual([[]], by: ==))
        
        XCTAssert(data.splitPlaces([2, -3, 4]).elementsEqual([[1, 2], [], [3, 4, 5, 6]], by: ==))
        XCTAssert(data.splitPlaces([2, 0, 4]).elementsEqual([[1, 2], [], [3, 4, 5, 6]], by: ==))
        XCTAssert(data.splitPlaces([2, 3, 5]).elementsEqual([[1, 2], [3, 4, 5], [6, 7, 8, 9, 0]], by: ==))
        XCTAssert(data.splitPlaces([2, 3, 4]).elementsEqual([[1, 2], [3, 4, 5], [6, 7, 8, 9]], by: ==))
        XCTAssert(data.splitPlaces([4, 9]).elementsEqual([[1, 2, 3, 4], [5, 6, 7, 8, 9, 0]], by: ==))
        XCTAssert(data.splitPlaces([4, 9, 10]).elementsEqual([[1, 2, 3, 4], [5, 6, 7, 8, 9, 0]], by: ==))
    }
}
