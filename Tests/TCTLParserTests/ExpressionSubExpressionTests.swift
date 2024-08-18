// ExpressionSubExpressionTests.swift
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

/// Test class for sub-expressions within an expression.
final class ExpressionSubExpressionTests: XCTestCase {

    /// Test sub-quantified expressions are parsed correctly.
    func testSubExpression() {
        guard
            let operationalMode = VariableName(rawValue: "operationalMode"),
            let bootMode = VariableName(rawValue: "bootMode")
        else {
            XCTFail("Incorrect variables names!")
            return
        }
        let expected = Expression.quantified(expression: .always(expression: .next(expression: .quantified(
            expression: .always(expression: .globally(expression: .implies(
                lhs: .language(expression: .vhdl(expression: .conditional(expression: .comparison(
                    value: .equality(
                        lhs: .reference(variable: .variable(reference: .variable(name: operationalMode))),
                        rhs: .literal(value: .bit(value: .high))
                    )
                )))),
                rhs: .quantified(expression: .eventually(expression: .until(
                    lhs: .language(expression: .vhdl(expression: .conditional(expression: .comparison(
                        value: .equality(
                            lhs: .reference(variable: .variable(reference: .variable(
                                name: operationalMode
                            ))),
                            rhs: .literal(value: .bit(value: .high))
                        )
                    )))),
                    rhs: .language(expression: .vhdl(expression: .conditional(
                        expression: .comparison(value: .equality(
                            lhs: .reference(variable: .variable(reference: .variable(name: bootMode))),
                            rhs: .literal(value: .bit(value: .high))
                        ))
                    )))
                )))
            )))
        ))))
        XCTAssertEqual(
            Expression(rawValue: "A X A G operationalMode = '1' -> E operationalMode = '1' U bootMode = '1'"),
            expected
        )
        XCTAssertEqual(
            Expression(
                rawValue: "A X A G operationalMode = \'1\' -> E operationalMode = \'1\' U bootMode = \'1\'"
            ),
            expected
        )
    }

    /// Test that negation works before a language expression.
    func testNegationInLanguage() {
        let falseExp = Expression.language(expression: .vhdl(expression: .conditional(
            expression: .literal(value: false)
        )))
        let expected = Expression.quantified(expression: .always(expression: .globally(
            expression: .not(expression: falseExp)
        )))
        XCTAssertEqual(Expression(rawValue: "A G !false"), expected)
    }

    /// Test that negation works for sub-expressions.
    func testNegationInSubExpression() {
        let falseExp = Expression.language(expression: .vhdl(expression: .conditional(
            expression: .literal(value: false)
        )))
        let expected = Expression.not(expression: .quantified(expression: .always(expression: .globally(
            expression: .not(expression: falseExp)
        ))))
        XCTAssertEqual(Expression(rawValue: "!A G !false"), expected)
    }

}
