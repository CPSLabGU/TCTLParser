// ConstrainedExpression.swift
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

/// An ``Expression`` with physical constraints applied to it.
/// 
/// A `ConstrainedExpression` is an ``Expression`` that is restricted by physical constraints. For example,
/// an expression may be constrained to execute within 100 nanoseconds, or without expending more than
/// 200 millijoules of energy. This structure allows the creation of such `ConstrainedExpressions`.
/// - SeeAlso: ``Expression``, ``ConstrainedStatement``.
public struct ConstrainedExpression: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The ``Expression`` to constrain.
    public let expression: Expression

    /// The constraints to apply to this expression. This array cannot be empty.
    public let constraints: [ConstrainedStatement]

    /// The equivalent `TCTL` string that defines the constrained expression.
    /// 
    /// The expression is surrounded in curly braces, with the constraints following an underscore and a
    /// comma-separated list also surrounded in curly braces. The full constrained expression is then
    /// `{expression}_{constraint1, constraint2, ...}`.
    @inlinable public var rawValue: String {
        "{\(expression.rawValue)}_{\(constraints.map(\.rawValue).joined(separator: ", "))}"
    }

    /// Create the constrained expression from it's `TCTL` representation.
    /// - Parameter rawValue: A string representing the `TCTL` expression definining the
    /// `ConstrainedExpression`.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.hasPrefix("{") else {
            return nil
        }
        let remaining = trimmedString.dropFirst()
        var terminatingIndex = 0
        var bracketCount = 1
        for (index, character) in remaining.enumerated() {
            guard character != "{" else {
                bracketCount += 1
                continue
            }
            if character == "}" {
                bracketCount -= 1
                guard bracketCount != 0 else {
                    terminatingIndex = index
                    break
                }
            }
        }
        guard bracketCount == 0 else {
            return nil
        }
        let expressionRaw = remaining[..<remaining.index(remaining.startIndex, offsetBy: terminatingIndex)]
        guard
            let expression = Expression(rawValue: String(expressionRaw)),
            remaining.count > terminatingIndex + 1
        else {
            return nil
        }
        let constraintsSection = remaining[
            remaining.index(remaining.startIndex, offsetBy: terminatingIndex + 1)...
        ]
        .trimmingCharacters(in: .whitespacesAndNewlines)
        guard constraintsSection.hasPrefix("_"), constraintsSection.hasSuffix("}") else {
            return nil
        }
        let withoutUnderscore = constraintsSection.dropFirst()
            .dropLast()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutUnderscore.hasPrefix("{") else {
            return nil
        }
        let constraintsRaw = withoutUnderscore.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
        let constraintsComponents = constraintsRaw.components(separatedBy: ",")
        let constraints = constraintsComponents.compactMap { ConstrainedStatement(rawValue: $0) }
        guard constraints.count == constraintsComponents.count, !constraints.isEmpty else {
            return nil
        }
        self.init(expression: expression, constraints: constraints)
    }

    /// Create the constrained expression from it's stored properties.
    /// - Parameters:
    ///   - expression: The expression to constrain.
    ///   - constraints: A non-empty array of constraints to apply to the `expression`.
    /// - Warning: An empty array of constraints will cause a fatal error.
    @inlinable
    public init(expression: Expression, constraints: [ConstrainedStatement]) {
        guard !constraints.isEmpty else {
            fatalError("Constraints cannot be empty!")
        }
        self.expression = expression
        self.constraints = constraints
    }

}
