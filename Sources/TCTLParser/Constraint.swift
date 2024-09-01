// Constraint.swift
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

import Foundation

/// A value representing some constraint on a physical quantity.
///
/// A `Constraint` is a value that constrains some physical quantity. The current supported constraints are
/// time and energy. Each constraint is represented as a unsigned value with a corresponding unit. For
/// example, a time constraint might be `5 ms` representing 5 milliseconds.
/// - SeeAlso: ``TimeUnit``, ``EnergyUnit``.
public enum Constraint: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// A time constraint.
    case time(amount: UInt, unit: TimeUnit)

    /// An energy constraint.
    case energy(amount: UInt, unit: EnergyUnit)

    /// The variable symbol representation of the constraint.
    ///
    /// The symbol of time is `t`, while the symbol of energy is `E`.
    @inlinable public var symbol: String {
        switch self {
        case .time:
            return "t"
        case .energy:
            return "E"
        }
    }

    /// The unsigned unitless amount of this constraint.
    @inlinable public var amount: UInt {
        switch self {
        case .time(let amount, _):
            return amount
        case .energy(let amount, _):
            return amount
        }
    }

    /// The string representation of the unit in this constraint.
    @inlinable public var unit: String {
        switch self {
        case .time(_, let unit):
            return unit.rawValue
        case .energy(_, let unit):
            return unit.rawValue
        }
    }

    /// The equivalent string representing the quantity of this constraint together with the `amount` and
    /// `unit`.
    @inlinable public var rawValue: String {
        "\(amount) \(unit)"
    }

    /// Create a constraint from it's `rawValue` representation.
    /// - Parameter rawValue: A string representation of the constraint.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = trimmedString.components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard components.count == 2, let amount = UInt(components[0]) else {
            return nil
        }
        if let timeUnit = TimeUnit(rawValue: components[1]) {
            self = .time(amount: amount, unit: timeUnit)
        } else if let energyUnit = EnergyUnit(rawValue: components[1]) {
            self = .energy(amount: amount, unit: energyUnit)
        } else {
            return nil
        }
    }

}
