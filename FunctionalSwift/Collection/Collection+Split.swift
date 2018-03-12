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

public extension Collection where Iterator.Element: Equatable {
    /// Returns the longest possible subsequences of the collection, in order,
    /// that don’t contain `element`.
    ///
    /// - Parameter element: Splitter.
    /// - Returns: An array of subsequences, split from this collection’s
    ///   elements.
    public func split(on element: Iterator.Element) -> [SubSequence] {
        return split { $0 == element }
    }

    /// Split on any of the given elements.
    ///
    /// - Parameter elements: Splitters.
    /// - Returns: An array of subsequences, split from this collection’s
    ///   elements.
    public func split<C: Collection>(oneOf elements: C)-> [SubSequence]
        where
        C.Iterator.Element == Iterator.Element {
        return split { elements.contains($0) }
    }
}

public extension Collection {
    /// `chunks(of: n)` splits a list into length-n pieces. The last piece will be
    /// shorter if `n` does not evenly divide the length of the list.
    /// If n <= 0, `chunksOf(n) returns an infinite list of empty lists.
    /// For example:
    ///
    ///     [-7, 5, 9].chunks(of: -1) = []
    ///
    /// Note that `[].chunksOf(n)` is `[]`, not `[[]]`. This is intentional,
    /// and is consistent with a recursive definition of chunksOf;
    /// it satisfies the property that
    ///
    ///     xs.chunks(of: n) + ys.chunks(of: n) == (xs + ys).chunks(of: n)
    ///
    ///   whenever n evenly divides the length of xs.
    ///
    /// - Parameter size: Size of chunk.
    /// - Returns: Array of length-size pieces.
    public func chunks(of size: Int) -> [SubSequence] {
        guard size > 0 else {
            return []
        }
        var result: [SubSequence] = []

        var subSequenceStart: Index = startIndex
        var subSequenceEnd: Index = startIndex

        var currentSize = 0

        while subSequenceEnd != endIndex {
            guard currentSize == size else {
                formIndex(after: &subSequenceEnd)
                currentSize += 1
                continue
            }
            result.append(self[subSequenceStart..<subSequenceEnd])
            subSequenceStart = subSequenceEnd
            currentSize = 0
        }

        if subSequenceStart != endIndex {
            result.append(self[subSequenceStart..<endIndex])
        }

        return  result
    }
    
    /// `split(places: [])` split a list into chunks of the given lengths.
    /// If the input list is longer than the total of the given lengths, then the remaining elements are dropped.
    /// If the list is shorter than the total of the given lengths,
    /// then the result may contain fewer chunks than requested, and the last chunk may be shorter than requested.
    ///
    /// If chunk <= 0, `split(places: [])` returns empty list.
    /// For example:
    ///
    ///     [-7, 5, 9].split(places: [-1]) = [[]]
    ///
    /// - Parameter places: List of chunks.
    /// - Returns: Array of chunks-size pieces.
    public func split(places: [Int]) -> [SubSequence] {
        guard let firstPlace = places.first else {
            return []
        }
        
        var result: [SubSequence] = []
        
        var subSequenceStart: Index = startIndex
        var subSequenceEnd: Index = startIndex
        
        var currentSize = 0
        var currentPlaceIndex = 0
        var currentPlace = firstPlace
        
        while subSequenceEnd != endIndex {
            guard currentSize == currentPlace || currentPlace <= 0 else {
                formIndex(after: &subSequenceEnd)
                currentSize += 1
                continue
            }
            result.append(self[subSequenceStart..<subSequenceEnd])
            subSequenceStart = subSequenceEnd
            currentSize = 0
            currentPlaceIndex += 1
            
            if currentPlaceIndex < places.count {
                currentPlace = places[currentPlaceIndex]
            } else {
                break
            }
        }
        
        if subSequenceStart != endIndex && currentPlaceIndex < places.count {
            result.append(self[subSequenceStart..<endIndex])
        }
        
        return result
    }
}
