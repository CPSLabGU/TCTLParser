// PathQuantifiedExpressionTests.swift
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

import Testing
import VHDLParsing

@testable import TCTLParser

/// Test class for ``PathQuantifiedExpression``.
@Suite("Path Quantified Expression Tests")
struct PathQuantifiedExpressionTests {

    /// The raw value of the test expression.
    let globalRawValue = "G recoveryMode = '1'"

    /// The raw value of the `nextExpression`.
    let nextRawValue = "X recoveryMode = '1'"

    /// The raw value of the `finalExpression`.
    let finalRawValue = "F recoveryMode = '1'"

    /// The `lhs` `rawValue`.
    let lhsRawValue = "recoveryMode = '1'"

    /// The `rhs` `rawValue`.
    let rhsRawValue = "failureCount = 3"

    /// The subexpression within the path quantified test expression.
    let subExpression = Expression.vhdl(
        expression: .conditional(
            expression: .comparison(
                value: .equality(
                    lhs: .reference(variable: .variable(reference: .variable(name: .recoveryMode))),
                    rhs: .literal(value: .bit(value: .high))
                )
            )
        )
    )

    /// The `lhs` operand.
    var lhs: TCTLParser.Expression { subExpression }

    /// The `rhs` operand.
    let rhs = TCTLParser.Expression.vhdl(
        expression: .conditional(
            expression: .comparison(
                value: .equality(
                    lhs: .reference(variable: .variable(reference: .variable(name: .failureCount))),
                    rhs: .literal(value: .integer(value: 3))
                )
            )
        )
    )

    /// A test global expression.
    var globalExpression: PathQuantifiedExpression {
        PathQuantifiedExpression.globally(expression: subExpression)
    }

    /// A test next expression.
    var nextExpression: PathQuantifiedExpression {
        .next(expression: subExpression)
    }

    /// A test finally expression.
    var finalExpression: PathQuantifiedExpression {
        .finally(expression: subExpression)
    }

    /// A test until expression.
    var untilExpression: PathQuantifiedExpression {
        .until(lhs: lhs, rhs: rhs)
    }

    /// A test weak expression.
    var weakExpression: PathQuantifiedExpression {
        .weak(lhs: lhs, rhs: rhs)
    }

    /// Test that the `rawValue` is generated correctly.
    @Test
    func testRawValue() {
        #expect(globalExpression.rawValue == globalRawValue)
        #expect(nextExpression.rawValue == nextRawValue)
        #expect(finalExpression.rawValue == finalRawValue)
        #expect(untilExpression.rawValue == "\(lhsRawValue) U \(rhsRawValue)")
        #expect(weakExpression.rawValue == "\(lhsRawValue) W \(rhsRawValue)")
    }

    /// Test that the `init?(rawValue:)` initializer works correctly.
    @Test
    func testRawValueInit() {
        #expect(PathQuantifiedExpression(rawValue: globalRawValue) == globalExpression)
        #expect(PathQuantifiedExpression(rawValue: nextRawValue) == nextExpression)
        #expect(PathQuantifiedExpression(rawValue: finalRawValue) == finalExpression)
        #expect(
            PathQuantifiedExpression(rawValue: "\(lhsRawValue) U \(rhsRawValue)") == untilExpression
        )
        #expect(
            PathQuantifiedExpression(rawValue: "\(lhsRawValue) W \(rhsRawValue)") == weakExpression)
        #expect(
            PathQuantifiedExpression(rawValue: "\(lhsRawValue)\nU\n\(rhsRawValue)")
                == untilExpression
        )
    }

    /// Test that the `init(rawValue:)` detects invalid raw values.
    @Test
    func testInvalidRawValue() {
        #expect(PathQuantifiedExpression(rawValue: "recoveryMode = '1'") == nil)
        #expect(PathQuantifiedExpression(rawValue: "GrecoveryMode = '1'") == nil)
        #expect(PathQuantifiedExpression(rawValue: "G recoveryMode == '1'") == nil)
        #expect(PathQuantifiedExpression(rawValue: "G G recoveryMode = '1'") == nil)
        #expect(PathQuantifiedExpression(rawValue: "") == nil)
        #expect(PathQuantifiedExpression(rawValue: "U") == nil)
        #expect(PathQuantifiedExpression(rawValue: "W") == nil)
        #expect(PathQuantifiedExpression(rawValue: "recoveryMode = '1' U") == nil)
        #expect(PathQuantifiedExpression(rawValue: "recoveryMode = '1' W") == nil)
        #expect(PathQuantifiedExpression(rawValue: "U recoveryMode = '1'") == nil)
        #expect(PathQuantifiedExpression(rawValue: "W recoveryMode = '1'") == nil)
        #expect(PathQuantifiedExpression(rawValue: " U recoveryMode = '1' ") == nil)
        #expect(PathQuantifiedExpression(rawValue: "recoveryMode = '1' U ") == nil)
        #expect(PathQuantifiedExpression(rawValue: "failureCount == 3 U recoveryMode = '1'") == nil)
        #expect(PathQuantifiedExpression(rawValue: "failureCount = 3 U recoveryMode == '1'") == nil)
    }

    /// Test `expression` computed property.
    @Test
    func testExpression() {
        #expect(globalExpression.expression == subExpression)
        #expect(nextExpression.expression == subExpression)
        #expect(finalExpression.expression == subExpression)
        #expect(untilExpression.expression == nil)
        #expect(weakExpression.expression == nil)
    }

    /// Test `lhs` computed propery.
    @Test
    func testLHS() {
        #expect(untilExpression.lhs == lhs)
        #expect(weakExpression.lhs == lhs)
        #expect(globalExpression.lhs == nil)
        #expect(nextExpression.lhs == nil)
        #expect(finalExpression.lhs == nil)
    }

    /// Test `rhs` computed property.
    @Test
    func testRHS() {
        #expect(untilExpression.rhs == rhs)
        #expect(weakExpression.rhs == rhs)
        #expect(globalExpression.rhs == nil)
        #expect(nextExpression.rhs == nil)
        #expect(finalExpression.rhs == nil)
    }

    /// Test that unary init.
    @Test
    func testUnaryInit() {
        #expect(
            PathQuantifiedExpression(unaryQuantifier: "G", expression: subExpression)
                == globalExpression)
        #expect(
            PathQuantifiedExpression(unaryQuantifier: "X", expression: subExpression)
                == nextExpression)
        #expect(
            PathQuantifiedExpression(unaryQuantifier: "F", expression: subExpression)
                == finalExpression)
        #expect(PathQuantifiedExpression(unaryQuantifier: "U", expression: subExpression) == nil)
        #expect(PathQuantifiedExpression(unaryQuantifier: "W", expression: subExpression) == nil)
        #expect(PathQuantifiedExpression(unaryQuantifier: "A", expression: subExpression) == nil)
        #expect(PathQuantifiedExpression(unaryQuantifier: "E", expression: subExpression) == nil)
    }

    /// Test the binary init.
    @Test
    func testBinaryInit() {
        #expect(
            PathQuantifiedExpression(binaryQuantifier: "U", lhs: lhs, rhs: rhs) == untilExpression)
        #expect(
            PathQuantifiedExpression(binaryQuantifier: "W", lhs: lhs, rhs: rhs) == weakExpression)
        #expect(PathQuantifiedExpression(binaryQuantifier: "G", lhs: lhs, rhs: rhs) == nil)
        #expect(PathQuantifiedExpression(binaryQuantifier: "X", lhs: lhs, rhs: rhs) == nil)
        #expect(PathQuantifiedExpression(binaryQuantifier: "F", lhs: lhs, rhs: rhs) == nil)
        #expect(PathQuantifiedExpression(binaryQuantifier: "A", lhs: lhs, rhs: rhs) == nil)
        #expect(PathQuantifiedExpression(binaryQuantifier: "E", lhs: lhs, rhs: rhs) == nil)
    }

}
