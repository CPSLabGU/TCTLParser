// SpecificationTests.swift
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

/// Test class for ``Specification``.
final class SpecificationTests: XCTestCase {

    /// The test `rawValue`.
    let rawValue = """
    // spec:language VHDL

    A G recoveryMode = '1'

    A G failureCount = 3

    """

    /// The test `rawValue` with comments.
    let rawValueWithComments = """
    // spec:language VHDL

    -- Another comment.
    -- Another comment2.

    -- A recovery mode requirement.
    A G recoveryMode = '1' -- Check recovery mode is high.
    -- Comment 3

    -- A failure count requirement.
    -- Multiline comment.
    A G failureCount = 3

    """

    /// The expected specification.
    let expected = Specification(
        configuration: Configuration(language: .vhdl),
        requirements: [
            .quantified(expression: .always(expression: .globally(expression: .vhdl(expression: .conditional(
                expression: .comparison(
                    value: .equality(
                        lhs: .reference(variable: .variable(reference: .variable(name: .recoveryMode))),
                        rhs: .literal(value: .bit(value: .high))
                    )
                )
            ))))),
            .quantified(expression: .always(expression: .globally(expression: .vhdl(expression: .conditional(
                expression: .comparison(value: .equality(
                    lhs: .reference(variable: .variable(reference: .variable(name: .failureCount))),
                    rhs: .literal(value: .integer(value: 3))
                ))
            )))))
        ]
    )

    /// Test that the `rawValue` is generated correctly.
    func testRawValue() {
        XCTAssertEqual(expected.rawValue, rawValue)
    }

    /// Test that the `init(rawValue:)` correctly parses the `TCTL` file with comments.
    func testRawValueWithCommentsInit() {
        XCTAssertEqual(Specification(rawValue: rawValueWithComments), expected)
    }

    /// Test that the `init(rawValue:)` correctly parses the `TCTL` file.
    func testRawValueInit() {
        XCTAssertEqual(Specification(rawValue: rawValue), expected)
        let configurationOnly = "// spec:language VHDL"
        XCTAssertEqual(
            Specification(rawValue: configurationOnly),
            Specification(configuration: Configuration(language: .vhdl), requirements: [])
        )
    }

    /// Test that the `init(rawValue:)` detects an invalid specification.
    func testInvalidRawValue() {
        XCTAssertNil(Specification(
            rawValue: "// spec:language VHDL\n\nA G recoveryMode = '1'\n\nA G failureCount == 3\n\n"
        ))
        XCTAssertNil(Specification(
            rawValue: "// spec:language VHDL\n\nA G recoveryMode = '1'\nA G failureCount = 3\n\n"
        ))
        XCTAssertNil(Specification(
            rawValue: "// spec:language VHDLA G recoveryMode = '1'\n\nA G failureCount == 3\n\n"
        ))
        XCTAssertNil(Specification(
            rawValue: "// spec:language undefined\n\nA G recoveryMode = '1'\n\nA G failureCount == 3\n\n"
        ))
        XCTAssertNil(Specification(
            rawValue: "A G recoveryMode = '1'\n\nA G failureCount == 3\n\n"
        ))
        XCTAssertNil(Specification(
            rawValue: "// spec:language none\n\n"
        ))
        XCTAssertNil(Specification(
            rawValue: ""
        ))
        XCTAssertNil(Specification(
            rawValue: "//"
        ))
    }

}
