// ConstraintTests.swift
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

/// Test class for ``Constraint``.
final class ConstraintTests: XCTestCase {

    /// A test time constraint.
    let timeConstraint = Constraint.time(amount: 100, unit: .ns)

    /// A test energy constraint.
    let energyConstraint = Constraint.energy(amount: 200, unit: .J)

    /// Test the symbol computed property.
    func testSymbol() {
        XCTAssertEqual(timeConstraint.symbol, "t")
        XCTAssertEqual(energyConstraint.symbol, "E")
    }

    /// Test that amount computed property.
    func testAmount() {
        XCTAssertEqual(timeConstraint.amount, 100)
        XCTAssertEqual(energyConstraint.amount, 200)
    }

    /// Test the unit computed property.
    func testUnit() {
        XCTAssertEqual(timeConstraint.unit, "ns")
        XCTAssertEqual(energyConstraint.unit, "J")
    }

    /// Test the raw value.
    func testRawValue() {
        XCTAssertEqual(timeConstraint.rawValue, "100 ns")
        XCTAssertEqual(energyConstraint.rawValue, "200 J")
    }

    /// Test that `init(rawValue:)` parses the raw value correctly.
    func testRawValueInit() {
        XCTAssertEqual(Constraint(rawValue: "100 ns"), timeConstraint)
        XCTAssertEqual(Constraint(rawValue: "200 J"), energyConstraint)
        XCTAssertEqual(Constraint(rawValue: "100\nns"), timeConstraint)
        XCTAssertEqual(Constraint(rawValue: "100    ns"), timeConstraint)
        XCTAssertEqual(Constraint(rawValue: "   100    ns  "), timeConstraint)
        XCTAssertEqual(Constraint(rawValue: "\n100\nns\n"), timeConstraint)
    }

    /// Test the `init(rawValue:)` detects invalid strings.
    func testInvalidRawValueInit() {
        XCTAssertNil(Constraint(rawValue: "100"))
        XCTAssertNil(Constraint(rawValue: "ns"))
        XCTAssertNil(Constraint(rawValue: "100 ns J"))
        XCTAssertNil(Constraint(rawValue: ""))
        XCTAssertNil(Constraint(rawValue: "100ns"))
        XCTAssertNil(Constraint(rawValue: "100 ns 1"))
        XCTAssertNil(Constraint(rawValue: "100"))
        XCTAssertNil(Constraint(rawValue: "     "))
        XCTAssertNil(Constraint(rawValue: " "))
    }

}
