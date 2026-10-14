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

import Testing
import VHDLParsing

@testable import TCTLParser

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Test class for ``Expression``.
struct ExpressionTests {

    /// The `rawValue` of the expression.
    let rawValue = "recoveryMode = '1'"

    /// A `rawValue` containing an `implies` case.
    let impliesRawValue = "failureCount = 3 -> recoveryMode = '1'"

    /// A `rawValue` containing an `equivalence` case.
    let equivalenceRawValue = "failureCount = 3 <-> recoveryMode = '1'"

    /// A `rawValue` containing multiple expressions.
    let subExpressionRawValue = "failureCount = 3 -> A G recoveryMode = '1' -> finished = '1'"

    /// The equivalent `VHDL` parsed format of `rawValue`.
    let vhdl = Expression.vhdl(
        expression: .conditional(
            expression: .comparison(
                value: .equality(
                    lhs: .reference(variable: .variable(reference: .variable(name: .recoveryMode))),
                    rhs: .literal(value: .bit(value: .high))
                )
            )
        )
    )

    /// The equivalent expression of `impliesRawValue`.
    let impliesExpression = Expression.implies(
        lhs: .vhdl(
            expression: .conditional(
                expression: .comparison(
                    value: .equality(
                        lhs: .reference(
                            variable: .variable(reference: .variable(name: .failureCount))),
                        rhs: .literal(value: .integer(value: 3))
                    )
                )
            )
        ),
        rhs: .vhdl(
            expression: .conditional(
                expression: .comparison(
                    value: .equality(
                        lhs: .reference(
                            variable: .variable(reference: .variable(name: .recoveryMode))),
                        rhs: .literal(value: .bit(value: .high))
                    )
                )
            )
        )
    )

    /// The equivalent expression of `impliesRawValue`.
    let equivalenceExpression = Expression.equivalence(
        lhs: .vhdl(
            expression: .conditional(
                expression: .comparison(
                    value: .equality(
                        lhs: .reference(
                            variable: .variable(reference: .variable(name: .failureCount))),
                        rhs: .literal(value: .integer(value: 3))
                    )
                )
            )
        ),
        rhs: .vhdl(
            expression: .conditional(
                expression: .comparison(
                    value: .equality(
                        lhs: .reference(
                            variable: .variable(reference: .variable(name: .recoveryMode))),
                        rhs: .literal(value: .bit(value: .high))
                    )
                )
            )
        )
    )

    /// The equivalent nested expression of `subExpressionRawValue`.
    let subExpression = Expression.implies(
        lhs: .vhdl(
            expression: .conditional(
                expression: .comparison(
                    value: .equality(
                        lhs: .reference(
                            variable: .variable(reference: .variable(name: .failureCount))),
                        rhs: .literal(value: .integer(value: 3))
                    )
                )
            )
        ),
        rhs: .quantified(
            expression: .always(
                expression: .globally(
                    expression: .implies(
                        lhs: .vhdl(
                            expression: .conditional(
                                expression: .comparison(
                                    value: .equality(
                                        lhs: .reference(
                                            variable: .variable(
                                                reference: .variable(name: .recoveryMode))
                                        ),
                                        rhs: .literal(value: .bit(value: .high))
                                    )
                                )
                            )
                        ),
                        rhs: .vhdl(
                            expression: .conditional(
                                expression: .comparison(
                                    value: .equality(
                                        lhs: .reference(
                                            variable: .variable(
                                                reference: .variable(name: .finished))
                                        ),
                                        rhs: .literal(value: .bit(value: .high))
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )

    /// A constrained expression.
    let constrainedExpression = Expression.constrained(
        expression: ConstrainedExpression(
            expression: .always(
                expression: .finally(
                    expression: .language(
                        expression: .vhdl(
                            expression: .conditional(
                                expression: .comparison(
                                    value: .equality(
                                        lhs: .reference(
                                            variable: .variable(
                                                reference: .variable(name: .recoveryMode))
                                        ),
                                        rhs: .literal(value: .bit(value: .high))
                                    )
                                )
                            )
                        )
                    )
                )
            ),
            constraints: [
                .lessThan(constraint: .time(amount: 100, unit: .ns)),
                .lessThan(constraint: .energy(amount: 200, unit: .mJ)),
            ]
        )
    )

    /// Test that the `rawValue` is generated correctly.
    @Test
    func testRawValue() {
        #expect(vhdl.rawValue == rawValue)
        #expect(impliesExpression.rawValue == impliesRawValue)
        #expect(equivalenceExpression.rawValue == equivalenceRawValue)
        #expect(subExpression.rawValue == subExpressionRawValue)
        #expect(TCTLParser.Expression.precedence(expression: vhdl).rawValue == "(\(rawValue))")
        #expect(TCTLParser.Expression.not(expression: vhdl).rawValue == "!\(rawValue)")
        #expect(
            TCTLParser.Expression.conjunction(lhs: vhdl, rhs: impliesExpression).rawValue
                == "\(rawValue) ^ \(impliesRawValue)"
        )
        #expect(
            TCTLParser.Expression.disjunction(lhs: vhdl, rhs: impliesExpression).rawValue
                == "\(rawValue) V \(impliesRawValue)"
        )
        #expect(
            constrainedExpression.rawValue == "{A F recoveryMode = '1'}_{t < 100 ns, E < 200 mJ}")
    }

    // swiftlint:disable function_body_length

    /// Test that the `init(rawValue:)` parses the expression correctly.
    @Test
    func testRawValueInit() {
        #expect(Expression(rawValue: rawValue) == vhdl)
        #expect(Expression(rawValue: impliesRawValue) == impliesExpression)
        #expect(Expression(rawValue: equivalenceRawValue) == equivalenceExpression)
        #expect(Expression(rawValue: subExpressionRawValue) == subExpression)
        #expect(Expression(rawValue: "(\(rawValue))") == .precedence(expression: vhdl))
        #expect(
            Expression(rawValue: "(\(subExpressionRawValue))")
                == .precedence(expression: subExpression)
        )
        #expect(
            Expression(rawValue: "(\(impliesRawValue)) -> finished = '1'")
                == .implies(
                    lhs: .precedence(expression: impliesExpression),
                    rhs: .vhdl(
                        expression: .conditional(
                            expression: .comparison(
                                value: .equality(
                                    lhs: .reference(
                                        variable: .variable(reference: .variable(name: .finished))),
                                    rhs: .literal(value: .bit(value: .high))
                                )
                            )
                        )
                    )
                )
        )
        #expect(
            Expression(rawValue: "(failureCount = 3) and (finished = '1')")
                == .vhdl(
                    expression: .boolean(
                        expression: .and(
                            lhs: .precedence(
                                value: .conditional(
                                    condition: .comparison(
                                        value: .equality(
                                            lhs: .reference(
                                                variable: .variable(
                                                    reference: .variable(name: .failureCount))
                                            ),
                                            rhs: .literal(value: .integer(value: 3))
                                        )
                                    )
                                )
                            ),
                            rhs: .precedence(
                                value: .conditional(
                                    condition: .comparison(
                                        value: .equality(
                                            lhs: .reference(
                                                variable: .variable(
                                                    reference: .variable(name: .finished))
                                            ),
                                            rhs: .literal(value: .bit(value: .high))
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
        )
        #expect(
            TCTLParser.Expression(rawValue: "A failureCount = 3 U recoveryMode = '1'")
                == .quantified(
                    expression: .always(
                        expression: .until(
                            lhs: .vhdl(
                                expression: .conditional(
                                    expression: .comparison(
                                        value: .equality(
                                            lhs: .reference(
                                                variable: .variable(
                                                    reference: .variable(name: .failureCount))
                                            ),
                                            rhs: .literal(value: .integer(value: 3))
                                        )
                                    )
                                )
                            ),
                            rhs: vhdl
                        )
                    )
                )
        )
        #expect(
            TCTLParser.Expression(rawValue: "!(recoveryMode = '1')")
                == .not(expression: .precedence(expression: vhdl))
        )
        #expect(
            TCTLParser.Expression(rawValue: "{A F recoveryMode = '1'}_{t < 100 ns, E < 200 mJ}")
                == constrainedExpression
        )
    }

    /// Test complex raw values in `init(rawValue:)`.
    @Test
    func testComplexRawValueInit() {
        #expect(
            TCTLParser.Expression(rawValue: "{A F recoveryMode = '1'}_{t < 100 ns, E < 200 mJ}   ")
                == constrainedExpression
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "{A F \(equivalenceRawValue)}_{t < 100 ns, E < 200 mJ}")
                == .constrained(
                    expression: ConstrainedExpression(
                        expression: .always(
                            expression: .finally(expression: equivalenceExpression)),
                        constraints: [
                            .lessThan(constraint: .time(amount: 100, unit: .ns)),
                            .lessThan(constraint: .energy(amount: 200, unit: .mJ)),
                        ]
                    ))
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "{A F recoveryMode = '1'}_{t < 100 ns, E < 200 mJ} -> recoveryMode = '1'"
            )
                == .implies(lhs: constrainedExpression, rhs: vhdl)
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "{A F recoveryMode = '1'}_{t < 100 ns, E < 200 mJ} ^ recoveryMode = '1'"
            )
                == .conjunction(lhs: constrainedExpression, rhs: vhdl)
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "recoveryMode = '1' ^ {A F recoveryMode = '1'}_{t < 100 ns, E < 200 mJ}"
            )
                == .conjunction(lhs: vhdl, rhs: constrainedExpression)
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "{A F recoveryMode = '1'}_{t < 100 ns, E < 200 mJ} "
                    + "^ {A F recoveryMode = '1'}_{t < 100 ns, E < 200 mJ}"
            )
                == .conjunction(lhs: constrainedExpression, rhs: constrainedExpression)
        )
        #expect(
            TCTLParser.Expression(
                rawValue: """
                    {A F recoveryMode = '1' ^ {A F recoveryMode = '1'}_{t < 100 ns, E < 200 mJ}}_{t < 200 ns}
                    """
            )
                == .constrained(
                    expression: ConstrainedExpression(
                        expression: .always(
                            expression: .finally(
                                expression: .conjunction(lhs: vhdl, rhs: constrainedExpression)
                            )
                        ),
                        constraints: [.lessThan(constraint: .time(amount: 200, unit: .ns))]
                    )
                )
        )
    }

    /// Test `init(rawValue:)` for logic operations.
    @Test
    func testLogicalRawValueInit() {
        #expect(
            TCTLParser.Expression(rawValue: "\(rawValue) ^ \(impliesRawValue)")
                == .conjunction(
                    lhs: vhdl,
                    rhs: impliesExpression
                )
        )
        #expect(
            TCTLParser.Expression(rawValue: "\(rawValue) V \(impliesRawValue)")
                == .disjunction(
                    lhs: vhdl,
                    rhs: impliesExpression
                )
        )
        let f: (VariableName) -> TCTLParser.Expression = {
            TCTLParser.Expression.language(
                expression: .vhdl(
                    expression: .conditional(
                        expression: .comparison(
                            value: .equality(
                                lhs: .reference(
                                    variable: .variable(reference: .variable(name: $0))),
                                rhs: .literal(value: .bit(value: .high))
                            )
                        )
                    )
                )
            )
        }
        #expect(
            TCTLParser.Expression(rawValue: "a = '1' ^ b = '1' V c = '1'")
                == .conjunction(
                    lhs: f(.a),
                    rhs: .disjunction(lhs: f(.b), rhs: f(.c))
                )
        )
        #expect(
            TCTLParser.Expression(rawValue: "(a = '1' ^ b = '1') V c = '1'")
                == .disjunction(
                    lhs: .precedence(expression: .conjunction(lhs: f(.a), rhs: f(.b))),
                    rhs: f(.c)
                )
        )
        #expect(
            TCTLParser.Expression(rawValue: "a = '1' ^ b = '1' V (c = '1')")
                == .conjunction(
                    lhs: f(.a),
                    rhs: .disjunction(lhs: f(.b), rhs: .precedence(expression: f(.c)))
                )
        )
        #expect(
            TCTLParser.Expression(rawValue: "!(a = '1' ^ b = '1') V c = '1'")
                == .disjunction(
                    lhs: .not(
                        expression: .precedence(expression: .conjunction(lhs: f(.a), rhs: f(.b)))),
                    rhs: f(.c)
                )
        )
        #expect(
            TCTLParser.Expression(rawValue: "a = '1' ^ b = '1' V !(c = '1')")
                == .conjunction(
                    lhs: f(.a),
                    rhs: .disjunction(
                        lhs: f(.b), rhs: .not(expression: .precedence(expression: f(.c))))
                )
        )
        #expect(
            TCTLParser.Expression(rawValue: "!(a = '1') ^ b = '1' V c = '1'")
                == .conjunction(
                    lhs: .not(expression: .precedence(expression: f(.a))),
                    rhs: .disjunction(lhs: f(.b), rhs: f(.c))
                )
        )
        #expect(
            TCTLParser.Expression(rawValue: "a = '1' ^ !(b = '1') V c = '1'")
                == .conjunction(
                    lhs: f(.a),
                    rhs: .disjunction(
                        lhs: .not(expression: .precedence(expression: f(.b))), rhs: f(.c))
                )
        )
    }

    /// Test that invalid `rawValue` returns `nil`.
    @Test
    func testInvalidRawValue() {
        #expect(TCTLParser.Expression(rawValue: "recoveryMode == '1'") == nil)
        #expect(TCTLParser.Expression(rawValue: "recoveryMode = '11'") == nil)
        #expect(TCTLParser.Expression(rawValue: "") == nil)
        #expect(TCTLParser.Expression(rawValue: " ") == nil)
        #expect(TCTLParser.Expression(rawValue: "failureCount = 3 ->") == nil)
        #expect(TCTLParser.Expression(rawValue: "failureCount = 3 -> recoveryMode = '11'") == nil)
        #expect(TCTLParser.Expression(rawValue: "failureCount == 3 -> recoveryMode = '1'") == nil)
        #expect(
            TCTLParser.Expression(
                rawValue: "failureCount = 3 -> A G recoveryMode = '1' -> finished == '1'") == nil
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "failureCount = 3 -> A G recoveryMode = '1' <- finished = '1'") == nil
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "failureCount = 3 -> A G recoveryMode = '1' finished == '1'") == nil
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "failureCount = 3 -> A S recoveryMode = '1' -> finished = '1'") == nil
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "failureCount = 3 -> A recoveryMode = '1' -> finished = '1'") == nil
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "failureCount = 3 -> G recoveryMode = '1' -> finished = '1'") == nil
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "failureCount = 3 -> G recoveryMode = '1' <- finished = '1'") == nil
        )
        #expect(TCTLParser.Expression(rawValue: "()") == nil)
        #expect(TCTLParser.Expression(precedence: rawValue) == nil)
        #expect(TCTLParser.Expression(rawValue: ")") == nil)
        #expect(TCTLParser.Expression(rawValue: "(") == nil)
        #expect(TCTLParser.Expression(rawValue: "(invalid!) -> finished = '1'") == nil)
        #expect(TCTLParser.Expression(rawValue: "(finished = '1') -> invalid!") == nil)
        #expect(TCTLParser.Expression(rawValue: "(finished = '1') and invalid!") == nil)
        #expect(TCTLParser.Expression(rawValue: "(invalid!)") == nil)
        #expect(TCTLParser.Expression(rawValue: "!") == nil)
        #expect(TCTLParser.Expression(rawValue: "(recoveryMode = '1')!") == nil)
        #expect(TCTLParser.Expression(rawValue: "!recoveryMode = '1'") == nil)
        #expect(TCTLParser.Expression(rawValue: "!not recoveryMode") == nil)
        #expect(TCTLParser.Expression(rawValue: "!!") == nil)
        #expect(TCTLParser.Expression(rawValue: "^") == nil)
        #expect(TCTLParser.Expression(rawValue: "V") == nil)
        #expect(TCTLParser.Expression(rawValue: "^ b = '1'") == nil)
        #expect(TCTLParser.Expression(rawValue: "a = '1' ^") == nil)
        #expect(TCTLParser.Expression(rawValue: "V b = '1'") == nil)
        #expect(TCTLParser.Expression(rawValue: "a = '1' V") == nil)
        #expect(TCTLParser.Expression(rawValue: "a == '1' ^ b = '1'") == nil)
        #expect(TCTLParser.Expression(rawValue: "a == '1' V b = '1'") == nil)
        #expect(TCTLParser.Expression(rawValue: "a = '1' ^ b == '1'") == nil)
        #expect(TCTLParser.Expression(rawValue: "a = '1' V b == '1'") == nil)
        #expect(TCTLParser.Expression(rawValue: "(a = '1') => b == '1'") == nil)
    }

    // swiftlint:enable function_body_length

    /// Test init(binaryOperation:,lhs:,rhs:).
    @Test
    func testBinaryOperationInit() {
        #expect(
            TCTLParser.Expression(binaryOperation: "^", lhs: vhdl, rhs: impliesExpression)
                == .conjunction(lhs: vhdl, rhs: impliesExpression)
        )
        #expect(
            TCTLParser.Expression(binaryOperation: "V", lhs: vhdl, rhs: impliesExpression)
                == .disjunction(lhs: vhdl, rhs: impliesExpression)
        )
        #expect(
            TCTLParser.Expression(binaryOperation: "->", lhs: vhdl, rhs: impliesExpression)
                == .implies(lhs: vhdl, rhs: impliesExpression)
        )
        #expect(
            TCTLParser.Expression(binaryOperation: "<->", lhs: vhdl, rhs: equivalenceExpression)
                == .equivalence(lhs: vhdl, rhs: equivalenceExpression)
        )
        #expect(
            TCTLParser.Expression(binaryOperation: "v", lhs: vhdl, rhs: impliesExpression) == nil)
    }

    /// Test `init(rawValue:)` for invalid constrained expressions.
    @Test
    func testInvalidConstrainedRawValue() {
        #expect(
            TCTLParser.Expression(rawValue: "{recoveryMode = '1'_{t < 100 ns, E < 200 mJ}") == nil)
        #expect(
            TCTLParser.Expression(rawValue: "{recoveryMode! = '1'}_{t < 100 ns, E < 200 mJ}") == nil
        )
        #expect(
            TCTLParser.Expression(
                rawValue: "{recoveryMode = '1'}_{t < 100 ns, E < 200 mJ} and x = '1'") == nil)
        #expect(
            TCTLParser.Expression(rawValue: "{recoveryMode = '1'}_{t < 100 ns,, E < 200 mJ}") == nil
        )
        #expect(
            TCTLParser.Expression(rawValue: "{A G {recoveryMode = '1'}_{t < 100 ns, E < 200 mJ}}")
                == nil)
        #expect(
            TCTLParser.Expression(constrained: "recoveryMode = '1'}_{t < 100 ns, E < 200 mJ}")
                == nil)
        #expect(
            TCTLParser.Expression(rawValue: "{recoveryMode = '1'}{t < 100 ns, E < 200 mJ}") == nil)
        #expect(
            TCTLParser.Expression(rawValue: "{recoveryMode = '1'}_t < 100 ns, E < 200 mJ}") == nil)
        #expect(
            TCTLParser.Expression(rawValue: "{recoveryMode = '1'}_{{t < 100 ns, E < 200 mJ}}")
                == nil)
        #expect(
            TCTLParser.Expression(rawValue: "{recoveryMode = '1'}_{t < 100 ns, E < 200 mJ") == nil)
        #expect(
            TCTLParser.Expression(rawValue: "{recoveryMode = '1'}_{t < 100 ns, E < 200 mJ} -> ><>")
                == nil)
        #expect(
            TCTLParser.Expression(rawValue: "{recoveryMode = '1'}_{t < 100 ns, E < 200 mJ} ^ ><>")
                == nil)
        #expect(
            TCTLParser.Expression(rawValue: "{recoveryMode = '1'}_{{t < 100 ns}, E < 200 mJ}")
                == nil)
    }

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
