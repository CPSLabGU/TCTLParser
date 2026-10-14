// ConstrainedStatementTests.swift
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

@testable import TCTLParser

/// Test class for ``ConstrainedStatement``.
@Suite("Constrained Statement Tests")
struct ConstrainedStatementTests {

    /// A time constraint of `100 ns`.
    let timeConstraint = Constraint.time(amount: 100, unit: .ns)

    /// A `lessThan` statement.
    var lessThan: ConstrainedStatement {
        ConstrainedStatement.lessThan(constraint: timeConstraint)
    }

    /// A `lessThanOrEqual` statement.
    var lessThanOrEqual: ConstrainedStatement {
        ConstrainedStatement.lessThanOrEqual(constraint: timeConstraint)
    }

    /// A `greaterThan` statement.
    var greaterThan: ConstrainedStatement {
        ConstrainedStatement.greaterThan(constraint: timeConstraint)
    }

    /// A `greaterThanOrEqual` statement.
    var greaterThanOrEqual: ConstrainedStatement {
        ConstrainedStatement.greaterThanOrEqual(constraint: timeConstraint)
    }

    /// A `equal` statement.
    var equal: ConstrainedStatement {
        ConstrainedStatement.equal(constraint: timeConstraint)
    }

    /// A `notEqual` statement.
    var notEqual: ConstrainedStatement {
        ConstrainedStatement.notEqual(constraint: timeConstraint)
    }

    /// Test that `rawValue` is created correctly.
    @Test
    func testRawValue() {
        #expect(lessThan.rawValue == "t < 100 ns")
        #expect(lessThanOrEqual.rawValue == "t <= 100 ns")
        #expect(greaterThan.rawValue == "t > 100 ns")
        #expect(greaterThanOrEqual.rawValue == "t >= 100 ns")
        #expect(equal.rawValue == "t == 100 ns")
        #expect(notEqual.rawValue == "t != 100 ns")
    }

    /// Test the `init(symbol:,operation:,constraint:)` creates the correct statement.
    @Test
    func testSymbolInit() {
        #expect(
            ConstrainedStatement(symbol: "t", operation: "<", constraint: timeConstraint)
                == lessThan
        )
        #expect(
            ConstrainedStatement(symbol: "t", operation: "<=", constraint: timeConstraint)
                == lessThanOrEqual
        )
        #expect(
            ConstrainedStatement(symbol: "t", operation: ">", constraint: timeConstraint)
                == greaterThan
        )
        #expect(
            ConstrainedStatement(symbol: "t", operation: ">=", constraint: timeConstraint)
                == greaterThanOrEqual
        )
        #expect(
            ConstrainedStatement(symbol: "t", operation: "==", constraint: timeConstraint)
                == equal
        )
        #expect(
            ConstrainedStatement(symbol: "t", operation: "!=", constraint: timeConstraint)
                == notEqual
        )
        #expect(
            ConstrainedStatement(symbol: "E", operation: "<", constraint: timeConstraint) == nil)
        #expect(
            ConstrainedStatement(symbol: "t", operation: "<<", constraint: timeConstraint) == nil)
    }

    /// Test the `init(rawValue:)` parses the raw value correctly.
    @Test
    func testRawValueInit() {
        #expect(ConstrainedStatement(rawValue: "t < 100 ns") == lessThan)
        #expect(ConstrainedStatement(rawValue: "t <= 100 ns") == lessThanOrEqual)
        #expect(ConstrainedStatement(rawValue: "t > 100 ns") == greaterThan)
        #expect(ConstrainedStatement(rawValue: "t >= 100 ns") == greaterThanOrEqual)
        #expect(ConstrainedStatement(rawValue: "t == 100 ns") == equal)
        #expect(ConstrainedStatement(rawValue: "t != 100 ns") == notEqual)
        #expect(ConstrainedStatement(rawValue: "   t    <    100    ns   ") == lessThan)
        #expect(ConstrainedStatement(rawValue: "\nt\n<\n100\nns\n") == lessThan)
    }

    /// Test that `init(rawValue:)` detects invalid raw values.
    @Test
    func testInvalidRawValueInit() {
        #expect(ConstrainedStatement(rawValue: "E < 100 ns") == nil)
        #expect(ConstrainedStatement(rawValue: "t << 100 ns") == nil)
        #expect(ConstrainedStatement(rawValue: "") == nil)
        #expect(ConstrainedStatement(rawValue: " ") == nil)
        #expect(ConstrainedStatement(rawValue: "t < 100 Ms") == nil)
        #expect(ConstrainedStatement(rawValue: "100 ns > t") == nil)
        #expect(ConstrainedStatement(rawValue: "< 100 ns") == nil)
        #expect(ConstrainedStatement(rawValue: "t <") == nil)
    }

}
