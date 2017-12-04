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

import Quick
import Nimble
import FunctionalSwift

class PreludeSpec: QuickSpec {
    override func spec() {
        describe("Identity function") {
            it("returns the same value that takes") {
                let a = 5
                let b = "Test"
                let c = true
                expect(id(a)).to(equal(a))
                expect(id(b)).to(equal(b))
                expect(id(c)).to(equal(c))
            }
        }
        
        describe("Const function") {
            it("returns a function that always returns the same value") {
                let a = "Test"
                expect(const(a)(5)).to(equal(a))
                expect(const(a)(1.5)).to(equal(a))
                expect(const(a)(true)).to(equal(a))
            }
        }
        
        describe("Function composition") {
            it("must return (A) -> C for (B) -> C and (A) -> B arguments") {
                struct A {}
                struct B {}
                struct C {}
                
                let kind = ((A) -> C).self
                
                let bc: (B) -> C = { _ in return C() }
                let ab: (A) -> B = { _ in return B() }
                expect(bc • ab).to(beAKindOf(kind))
            }
            
            context("that takes arguments bc and ab") {
                it("must first apply to the argument ab, then bc") {
                    let bc = { $0 * 2 }
                    let ab = { $0 + 2 }
                    
                    let a = 5
                    let c = bc(ab(5))
                    expect((bc • ab)(a)).to(equal(c))
                }
            }
        }
        
        describe("Application operator") {
            it("apply function to argument") {
                let a: (Int) -> Int = { $0 * 2 }
                let b = 5
                
                expect(a <| b).to(equal(a(b)))
                expect(b |> a).to(equal(a(b)))
            }
        }
    }
}
