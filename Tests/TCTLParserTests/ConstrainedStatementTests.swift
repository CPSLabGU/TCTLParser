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

@testable import TCTLParser
import XCTest

/// Test class for ``ConstrainedStatement``.
final class ConstrainedStatementTests: XCTestCase {

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
    func testRawValue() {
        XCTAssertEqual(lessThan.rawValue, "t < 100 ns")
        XCTAssertEqual(lessThanOrEqual.rawValue, "t <= 100 ns")
        XCTAssertEqual(greaterThan.rawValue, "t > 100 ns")
        XCTAssertEqual(greaterThanOrEqual.rawValue, "t >= 100 ns")
        XCTAssertEqual(equal.rawValue, "t == 100 ns")
        XCTAssertEqual(notEqual.rawValue, "t != 100 ns")
    }

    /// Test the `init(symbol:,operation:,constraint:)` creates the correct statement.
    func testSymbolInit() {
        XCTAssertEqual(
            ConstrainedStatement(symbol: "t", operation: "<", constraint: timeConstraint), lessThan
        )
        XCTAssertEqual(
            ConstrainedStatement(symbol: "t", operation: "<=", constraint: timeConstraint), lessThanOrEqual
        )
        XCTAssertEqual(
            ConstrainedStatement(symbol: "t", operation: ">", constraint: timeConstraint), greaterThan
        )
        XCTAssertEqual(
            ConstrainedStatement(symbol: "t", operation: ">=", constraint: timeConstraint), greaterThanOrEqual
        )
        XCTAssertEqual(
            ConstrainedStatement(symbol: "t", operation: "==", constraint: timeConstraint), equal
        )
        XCTAssertEqual(
            ConstrainedStatement(symbol: "t", operation: "!=", constraint: timeConstraint), notEqual
        )
        XCTAssertNil(ConstrainedStatement(symbol: "E", operation: "<", constraint: timeConstraint))
        XCTAssertNil(ConstrainedStatement(symbol: "t", operation: "<<", constraint: timeConstraint))
    }

    /// Test the `init(rawValue:)` parses the raw value correctly.
    func testRawValueInit() {
        XCTAssertEqual(ConstrainedStatement(rawValue: "t < 100 ns"), lessThan)
        XCTAssertEqual(ConstrainedStatement(rawValue: "t <= 100 ns"), lessThanOrEqual)
        XCTAssertEqual(ConstrainedStatement(rawValue: "t > 100 ns"), greaterThan)
        XCTAssertEqual(ConstrainedStatement(rawValue: "t >= 100 ns"), greaterThanOrEqual)
        XCTAssertEqual(ConstrainedStatement(rawValue: "t == 100 ns"), equal)
        XCTAssertEqual(ConstrainedStatement(rawValue: "t != 100 ns"), notEqual)
        XCTAssertEqual(ConstrainedStatement(rawValue: "   t    <    100    ns   "), lessThan)
        XCTAssertEqual(ConstrainedStatement(rawValue: "\nt\n<\n100\nns\n"), lessThan)
    }

    /// Test that `init(rawValue:)` detects invalid raw values.
    func testInvalidRawValueInit() {
        XCTAssertNil(ConstrainedStatement(rawValue: "E < 100 ns"))
        XCTAssertNil(ConstrainedStatement(rawValue: "t << 100 ns"))
        XCTAssertNil(ConstrainedStatement(rawValue: ""))
        XCTAssertNil(ConstrainedStatement(rawValue: " "))
        XCTAssertNil(ConstrainedStatement(rawValue: "t < 100 Ms"))
        XCTAssertNil(ConstrainedStatement(rawValue: "100 ns > t"))
        XCTAssertNil(ConstrainedStatement(rawValue: "< 100 ns"))
        XCTAssertNil(ConstrainedStatement(rawValue: "t <"))
    }

}
