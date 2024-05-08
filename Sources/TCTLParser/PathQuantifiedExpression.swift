// PathQuantifiedExpression.swift
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

/// A Path-Qualified Expression.
///
/// These expressions applies rules to a specific-path within the `TCTL` branching model.
public indirect enum PathQuantifiedExpression: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The `expression` must apply to all states within the current path.
    /// 
    /// The syntax of this expression in `TCTL` is `G <expression>`.
    case globally(expression: Expression)

    /// The `expression` must apply to the immediate next state within the current path.
    /// 
    /// The syntax of this expression in `TCTL` is `X <expression>`.
    case next(expression: Expression)

    /// The `expression` must apply to some state within the current path.
    /// 
    /// The syntax of this expression in `TCTL` is `F <expression>`.
    case finally(expression: Expression)

    /// The `lhs` expression must hold in the current path until `rhs` holds.
    /// 
    /// The syntax of this expression in `TCTL` is `<lhs> U <rhs>`.
    case until(lhs: Expression, rhs: Expression)

    /// The `lhs` expression must hold in the current path until `rhs` holds but without any guarantee that
    /// `rhs` will ever hold.
    /// 
    /// The syntax of this expression in `TCTL` is `<lhs> W <rhs>`.
    case weak(lhs: Expression, rhs: Expression)

    /// The ``Expression`` this path quantifier applies too.
    /// 
    /// This property is only available for unary quantifiers (i.e. `G`, `X`, `F`). For binary quantifiers
    /// this property will return `nil`.
    @inlinable public var expression: Expression? {
        switch self {
        case .globally(let expression), .next(let expression), .finally(let expression):
            return expression
        default:
            return nil
        }
    }

    /// The left-hand side ``Expression`` of the binary quantifier.
    /// 
    /// This property is only available for binary quantifiers (i.e. `U`, `W`). For unary quantifiers this
    /// property will return `nil`.
    @inlinable public var lhs: Expression? {
        switch self {
        case .until(let lhs, _), .weak(let lhs, _):
            return lhs
        default:
            return nil
        }
    }

    /// The right-hand side ``Expression`` of the binary quantifier.
    /// 
    /// This property is only available for binary quantifiers (i.e. `U`, `W`). For unary quantifiers this
    /// property will return `nil`.
    @inlinable public var rhs: Expression? {
        switch self {
        case .until(_, let rhs), .weak(_, let rhs):
            return rhs
        default:
            return nil
        }
    }

    /// The equivalent `TCTL` notation for the path-quantified expression.
    @inlinable public var rawValue: String {
        switch self {
        case .globally(let expression):
            return "G \(expression.rawValue)"
        case .next(let expression):
            return "X \(expression.rawValue)"
        case .finally(let expression):
            return "F \(expression.rawValue)"
        case .until(let lhs, let rhs):
            return "\(lhs.rawValue) U \(rhs.rawValue)"
        case .weak(let lhs, let rhs):
            return "\(lhs.rawValue) W \(rhs.rawValue)"
        }
    }

    /// Creates a new path-quantified expression from the given `TCTL` expression.
    /// - Parameter rawValue: The `TCTL` expression defining this path-quantified expression.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let firstChar = trimmedString.first, CharacterSet.pathQuantifiers.contains(character: firstChar)
        else {
            self.init(binaryQuantified: trimmedString)
            return
        }
        let remaining = String(trimmedString.dropFirst(1))
        guard
            let secondChar = remaining.first,
            CharacterSet.whitespacesAndNewlines.contains(character: secondChar)
        else {
            self.init(binaryQuantified: trimmedString)
            return
        }
        guard let expression = Expression(rawValue: remaining) else {
            return nil
        }
        self.init(unaryQuantifier: firstChar, expression: expression)
    }

    /// Initialise this path-quantified expression from the unary quantifier and the expression the quantifier
    /// applies too.
    /// - Parameters:
    ///   - quantifier: The unary quantifier. Valid values are `"G"`, `"X"`, and `"F"`.
    ///   - expression: The expression the quantifier applies too.
    @inlinable
    public init?(unaryQuantifier quantifier: Character, expression: Expression) {
        switch quantifier {
        case "G":
            self = .globally(expression: expression)
        case "X":
            self = .next(expression: expression)
        case "F":
            self = .finally(expression: expression)
        default:
            return nil
        }
    }

    /// Initialise this path-quantified expression from the binary quantifier and the expressions the
    /// quantifier applies too.
    /// - Parameters:
    ///   - quantifier: The binary quantifier. Valid values are `"U"` and `"W"`.
    ///   - lhs: The left-hand side expression.
    ///   - rhs: The right-hand side expression.
    @inlinable
    public init?(binaryQuantifier quantifier: Character, lhs: Expression, rhs: Expression) {
        switch quantifier {
        case "U":
            self = .until(lhs: lhs, rhs: rhs)
        case "W":
            self = .weak(lhs: lhs, rhs: rhs)
        default:
            return nil
        }
    }

    /// Initialise this path-quantified expression from the raw value assuming it is a binary quantified
    /// expression.
    /// - Parameter rawValue: A `TCTL` string representing the binary path-quantified expression.
    @inlinable
    init?(binaryQuantified rawValue: String) {
        let quantifierIndexes: [Range<String.Index>] = ["U", "W"].compactMap {
            guard
                let range = rawValue.range(of: "\($0)"),
                range.lowerBound > rawValue.startIndex,
                range.upperBound < rawValue.endIndex,
                let charBefore = rawValue[..<range.lowerBound].last,
                CharacterSet.whitespacesAndNewlines.contains(character: charBefore),
                CharacterSet.whitespacesAndNewlines.contains(character: rawValue[range.upperBound])
            else {
                return nil
            }
            return range
        }
        guard
            let firstQuantifierIndex = quantifierIndexes.min(by: { $0.lowerBound < $1.lowerBound }),
            firstQuantifierIndex.lowerBound > rawValue.startIndex
        else {
            return nil
        }
        let firstQuantifier = rawValue[firstQuantifierIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let quantifierChar = firstQuantifier[firstQuantifier.startIndex]
        let lhsRaw = rawValue[..<firstQuantifierIndex.lowerBound]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let rhsRaw = rawValue[firstQuantifierIndex.upperBound...]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lhs = Expression(rawValue: lhsRaw), let rhs = Expression(rawValue: rhsRaw) else {
            return nil
        }
        self.init(binaryQuantifier: quantifierChar, lhs: lhs, rhs: rhs)
    }

}
