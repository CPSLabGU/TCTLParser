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

@testable import TCTLParser
import VHDLParsing
import XCTest

/// Test class for ``PathQuantifiedExpression``.
final class PathQuantifiedExpressionTests: XCTestCase {

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
    func testRawValue() {
        XCTAssertEqual(globalExpression.rawValue, globalRawValue)
        XCTAssertEqual(nextExpression.rawValue, nextRawValue)
        XCTAssertEqual(finalExpression.rawValue, finalRawValue)
        XCTAssertEqual(untilExpression.rawValue, "\(lhsRawValue) U \(rhsRawValue)")
        XCTAssertEqual(weakExpression.rawValue, "\(lhsRawValue) W \(rhsRawValue)")
    }

    /// Test that the `init?(rawValue:)` initializer works correctly.
    func testRawValueInit() {
        XCTAssertEqual(PathQuantifiedExpression(rawValue: globalRawValue), globalExpression)
        XCTAssertEqual(PathQuantifiedExpression(rawValue: nextRawValue), nextExpression)
        XCTAssertEqual(PathQuantifiedExpression(rawValue: finalRawValue), finalExpression)
        XCTAssertEqual(PathQuantifiedExpression(rawValue: "\(lhsRawValue) U \(rhsRawValue)"), untilExpression)
        XCTAssertEqual(PathQuantifiedExpression(rawValue: "\(lhsRawValue) W \(rhsRawValue)"), weakExpression)
        XCTAssertEqual(
            PathQuantifiedExpression(rawValue: "\(lhsRawValue)\nU\n\(rhsRawValue)"),
            untilExpression
        )
    }

    /// Test that the `init(rawValue:)` detects invalid raw values.
    func testInvalidRawValue() {
        XCTAssertNil(PathQuantifiedExpression(rawValue: "recoveryMode = '1'"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "GrecoveryMode = '1'"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "G recoveryMode == '1'"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "G G recoveryMode = '1'"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: ""))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "U"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "W"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "recoveryMode = '1' U"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "recoveryMode = '1' W"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "U recoveryMode = '1'"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "W recoveryMode = '1'"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: " U recoveryMode = '1' "))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "recoveryMode = '1' U "))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "failureCount == 3 U recoveryMode = '1'"))
        XCTAssertNil(PathQuantifiedExpression(rawValue: "failureCount = 3 U recoveryMode == '1'"))
    }

    /// Test `expression` computed property.
    func testExpression() {
        XCTAssertEqual(globalExpression.expression, subExpression)
        XCTAssertEqual(nextExpression.expression, subExpression)
        XCTAssertEqual(finalExpression.expression, subExpression)
        XCTAssertNil(untilExpression.expression)
        XCTAssertNil(weakExpression.expression)
    }

    /// Test `lhs` computed propery.
    func testLHS() {
        XCTAssertEqual(untilExpression.lhs, lhs)
        XCTAssertEqual(weakExpression.lhs, lhs)
        XCTAssertNil(globalExpression.lhs)
        XCTAssertNil(nextExpression.lhs)
        XCTAssertNil(finalExpression.lhs)
    }

    /// Test `rhs` computed property.
    func testRHS() {
        XCTAssertEqual(untilExpression.rhs, rhs)
        XCTAssertEqual(weakExpression.rhs, rhs)
        XCTAssertNil(globalExpression.rhs)
        XCTAssertNil(nextExpression.rhs)
        XCTAssertNil(finalExpression.rhs)
    }

    /// Test that unary init.
    func testUnaryInit() {
        XCTAssertEqual(
            PathQuantifiedExpression(unaryQuantifier: "G", expression: subExpression),
            globalExpression
        )
        XCTAssertEqual(
            PathQuantifiedExpression(unaryQuantifier: "X", expression: subExpression),
            nextExpression
        )
        XCTAssertEqual(
            PathQuantifiedExpression(unaryQuantifier: "F", expression: subExpression),
            finalExpression
        )
        XCTAssertNil(PathQuantifiedExpression(unaryQuantifier: "U", expression: subExpression))
        XCTAssertNil(PathQuantifiedExpression(unaryQuantifier: "W", expression: subExpression))
        XCTAssertNil(PathQuantifiedExpression(unaryQuantifier: "A", expression: subExpression))
        XCTAssertNil(PathQuantifiedExpression(unaryQuantifier: "E", expression: subExpression))
    }

    /// Test the binary init.
    func testBinaryInit() {
        XCTAssertEqual(PathQuantifiedExpression(binaryQuantifier: "U", lhs: lhs, rhs: rhs), untilExpression)
        XCTAssertEqual(PathQuantifiedExpression(binaryQuantifier: "W", lhs: lhs, rhs: rhs), weakExpression)
        XCTAssertNil(PathQuantifiedExpression(binaryQuantifier: "G", lhs: lhs, rhs: rhs))
        XCTAssertNil(PathQuantifiedExpression(binaryQuantifier: "X", lhs: lhs, rhs: rhs))
        XCTAssertNil(PathQuantifiedExpression(binaryQuantifier: "F", lhs: lhs, rhs: rhs))
        XCTAssertNil(PathQuantifiedExpression(binaryQuantifier: "A", lhs: lhs, rhs: rhs))
        XCTAssertNil(PathQuantifiedExpression(binaryQuantifier: "E", lhs: lhs, rhs: rhs))
    }

}
