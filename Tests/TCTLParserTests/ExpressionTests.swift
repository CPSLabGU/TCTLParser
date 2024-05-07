// ExpressionTests.swift
// TCTLParser
// 
// Created by Morgan McColl.
// Copyright © 2024 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.

@testable import TCTLParser
import VHDLParsing
import XCTest

/// Test class for ``Expression``.
final class ExpressionTests: XCTestCase {

    /// The `rawValue` of the expression.
    let rawValue = "recoveryMode = '1'"

    /// A `rawValue` containing an `implies` case.
    let impliesRawValue = "failureCount = 3 -> recoveryMode = '1'"

    /// A `rawValue` containing multiple expressions.
    let subExpressionRawValue = "failureCount = 3 -> A G recoveryMode = '1' -> finished = '1'"

    /// The equivalent `VHDL` parsed format of `rawValue`.
    let vhdl = Expression.vhdl(expression: .conditional(expression: .comparison(value: .equality(
        lhs: .reference(variable: .variable(reference: .variable(name: .recoveryMode))),
        rhs: .literal(value: .bit(value: .high))
    ))))

    /// The equivalent expression of `impliesRawValue`.
    let impliesExpression = Expression.implies(
        lhs: .vhdl(expression: .conditional(expression: .comparison(value: .equality(
            lhs: .reference(variable: .variable(reference: .variable(name: .failureCount))),
            rhs: .literal(value: .integer(value: 3))
        )))),
        rhs: .expression(expression: .vhdl(expression: .conditional(expression: .comparison(value: .equality(
            lhs: .reference(variable: .variable(reference: .variable(name: .recoveryMode))),
            rhs: .literal(value: .bit(value: .high))
        )))))
    )

    /// The equivalent nested expression of `subExpressionRawValue`.
    let subExpression = Expression.implies(
        lhs: .vhdl(expression: .conditional(expression: .comparison(value: .equality(
            lhs: .reference(variable: .variable(reference: .variable(name: .failureCount))),
            rhs: .literal(value: .integer(value: 3))
        )))),
        rhs: .quantified(expression: .always(expression: .globally(
            expression: .implies(
                lhs: .vhdl(expression: .conditional(expression: .comparison(value: .equality(
                    lhs: .reference(variable: .variable(reference: .variable(name: .recoveryMode))),
                    rhs: .literal(value: .bit(value: .high))
                )))),
                rhs: .expression(expression: .vhdl(
                    expression: .conditional(
                        expression: .comparison(value: .equality(
                            lhs: .reference(variable: .variable(reference: .variable(name: .finished))),
                            rhs: .literal(value: .bit(value: .high))
                        ))
                    )
                ))
            )
        )))
    )

    /// Test that the `rawValue` is generated correctly.
    func testRawValue() {
        XCTAssertEqual(vhdl.rawValue, rawValue)
        XCTAssertEqual(impliesExpression.rawValue, impliesRawValue)
        XCTAssertEqual(subExpression.rawValue, subExpressionRawValue)
    }

    /// Test that the `init(rawValue:)` parses the expression correctly.
    func testRawValueInit() {
        XCTAssertEqual(Expression(rawValue: rawValue), vhdl)
        XCTAssertEqual(Expression(rawValue: impliesRawValue), impliesExpression)
        XCTAssertEqual(Expression(rawValue: subExpressionRawValue), subExpression)
    }

    /// Test that invalid `rawValue` returns `nil`.
    func testInvalidRawValue() {
        XCTAssertNil(TCTLParser.Expression(rawValue: "recoveryMode == '1'"))
        XCTAssertNil(TCTLParser.Expression(rawValue: "recoveryMode = '11'"))
        XCTAssertNil(TCTLParser.Expression(rawValue: ""))
        XCTAssertNil(TCTLParser.Expression(rawValue: " "))
        XCTAssertNil(TCTLParser.Expression(rawValue: "failureCount = 3 ->"))
        XCTAssertNil(TCTLParser.Expression(rawValue: "failureCount = 3 -> recoveryMode = '11'"))
        XCTAssertNil(TCTLParser.Expression(rawValue: "failureCount == 3 -> recoveryMode = '1'"))
        XCTAssertNil(
            TCTLParser.Expression(rawValue: "failureCount = 3 -> A G recoveryMode = '1' -> finished == '1'")
        )
        XCTAssertNil(
            TCTLParser.Expression(rawValue: "failureCount = 3 -> A G recoveryMode = '1' finished == '1'")
        )
        XCTAssertNil(
            TCTLParser.Expression(rawValue: "failureCount = 3 -> A S recoveryMode = '1' -> finished = '1'")
        )
        XCTAssertNil(
            TCTLParser.Expression(rawValue: "failureCount = 3 -> A recoveryMode = '1' -> finished = '1'")
        )
        XCTAssertNil(
            TCTLParser.Expression(rawValue: "failureCount = 3 -> G recoveryMode = '1' -> finished = '1'")
        )
    }

}
