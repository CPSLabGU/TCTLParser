// Expression.swift
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

/// A `TCTL` expression.
///
/// This `enum` represents the foundational `TCTL` expressions that can be `quantified`. Instances of this
/// type are not valid on their own, but must also be quantified using ``GloballyQuantifiedExpression`` and
/// ``PathQuantifiedExpression``.
public indirect enum Expression: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// A `TCTL` expression that states that `lhs` implies `rhs`.
    ///
    /// The syntax for this expression is `<lhs> -> <rhs>`.
    case implies(lhs: Expression, rhs: Expression)

    /// A `TCTL` expression that is globally quantified.
    case quantified(expression: GloballyQuantifiedExpression)

    /// The `TCTL` expression has precedence (paranthesis around the expression).
    case precedence(expression: Expression)

    /// A `TCTL` expression that contains language-specific code.
    ///
    /// - Note: Current supported languages are defined in the ``Language`` enum and ``LanguageExpression``
    /// enum.
    case language(expression: LanguageExpression)

    /// A `TCTL` expression that is negated.
    case not(expression: Expression)

    /// A `TCTL` conjunction between two expressions.
    case conjunction(lhs: Expression, rhs: Expression)

    /// A `TCTL` disjunction between two expressions.
    case disjunction(lhs: Expression, rhs: Expression)

    /// An `Expression` constrained by a physical constraint.
    case constrained(expression: ConstrainedExpression)

    /// The equivalent `TCTL` expression as a string.
    @inlinable public var rawValue: String {
        switch self {
        case .implies(let lhs, let rhs):
            return "\(lhs.rawValue) -> \(rhs.rawValue)"
        case .quantified(let expression):
            return expression.rawValue
        case .precedence(let expression):
            return "(\(expression.rawValue))"
        case .language(let expression):
            return expression.rawValue
        case .not(let expression):
            return "!\(expression.rawValue)"
        case .conjunction(let lhs, let rhs):
            return "\(lhs.rawValue) ^ \(rhs.rawValue)"
        case .disjunction(let lhs, let rhs):
            return "\(lhs.rawValue) V \(rhs.rawValue)"
        case .constrained(let expression):
            return expression.rawValue
        }
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length

    /// Create the expression from the `TCTL` expression as a string.
    /// - Parameter rawValue: The `TCTL` expression as a string.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.hasPrefix("!") else {
            self.init(not: String(trimmedString.dropFirst()))
            return
        }
        guard !trimmedString.hasPrefix("{") else {
            self.init(constrained: trimmedString)
            return
        }
        if trimmedString.count >= 2 {
            let prefixString = trimmedString[
                trimmedString.startIndex...trimmedString.index(after: trimmedString.startIndex)
            ]
            .trimmingCharacters(in: .whitespacesAndNewlines)
            if prefixString.count == 1 {
                let firstChar = prefixString[prefixString.startIndex]
                if CharacterSet.globalQuantifiers.contains(character: firstChar) {
                    guard let quantified = GloballyQuantifiedExpression(rawValue: trimmedString) else {
                        return nil
                    }
                    self = .quantified(expression: quantified)
                    return
                }
            }
        }
        if trimmedString.first == "(" {
            self.init(precedence: trimmedString)
            return
        }
        if let logicalExpression = Expression(logical: trimmedString) {
            self = logicalExpression
            return
        }
        guard let impliesIndex = trimmedString.range(of: "->") else {
            guard let expression = LanguageExpression(rawValue: trimmedString) else {
                return nil
            }
            self = .language(expression: expression)
            return
        }
        let lhsRaw = trimmedString[..<impliesIndex.lowerBound]
        guard impliesIndex.upperBound < trimmedString.index(before: trimmedString.endIndex) else {
            return nil
        }
        let rhsRaw = trimmedString[trimmedString.index(after: impliesIndex.upperBound)...]
        guard
            let lhs = Expression(rawValue: String(lhsRaw)), let rhs = Expression(rawValue: String(rhsRaw))
        else {
            return nil
        }
        self = .implies(lhs: lhs, rhs: rhs)
    }

    // swiftlint:enable function_body_length
    // swiftlint:disable function_body_length

    /// Create an `Expression` assuming the raw value starts with a constrained expression.
    /// - Parameter rawValue: The `TCTL` string to parse.
    @inlinable
    init?(constrained rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.hasPrefix("{") else {
            return nil
        }
        var bracketCount = 0
        var terminationIndex = 0
        for (index, character) in trimmedString.enumerated() {
            guard character != "{" else {
                bracketCount += 1
                continue
            }
            if character == "}" {
                bracketCount -= 1
                guard bracketCount != 0 else {
                    terminationIndex = index
                    break
                }
            }
        }
        guard
            bracketCount == 0,
            trimmedString.endIndex.utf16Offset(in: trimmedString) > terminationIndex + 2
        else {
            return nil
        }
        let firstHalf = trimmedString[
            ...trimmedString.index(trimmedString.startIndex, offsetBy: terminationIndex)
        ]
        let secondHalfRaw = trimmedString[
            trimmedString.index(trimmedString.startIndex, offsetBy: terminationIndex + 1)...
        ]
        .trimmingCharacters(in: .whitespacesAndNewlines)
        guard secondHalfRaw.hasPrefix("_") else {
            return nil
        }
        let withoutUnderscore = secondHalfRaw.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
        guard withoutUnderscore.hasPrefix("{") else {
            return nil
        }
        let withoutStart = withoutUnderscore.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let terminationIndex2 = withoutStart.firstIndex(of: "}") else {
            return nil
        }
        let secondHalf = "_{" + withoutStart[...terminationIndex2]
        guard let expression = ConstrainedExpression(rawValue: firstHalf + secondHalf) else {
            return nil
        }
        guard terminationIndex2 != withoutStart.index(before: withoutStart.endIndex) else {
            self = .constrained(expression: expression)
            return
        }
        let remaining = withoutStart[withoutStart.index(after: terminationIndex2)...]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !remaining.hasPrefix("->") else {
            let rhsRaw = remaining.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let rhs = Expression(rawValue: rhsRaw) else {
                return nil
            }
            self = .implies(lhs: .constrained(expression: expression), rhs: rhs)
            return
        }
        guard
            let first = remaining.first, CharacterSet.binaryLogicalOperators.contains(character: first)
        else {
            return nil
        }
        let rhsRaw = remaining.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let rhs = Expression(rawValue: rhsRaw) else {
            return nil
        }
        self.init(binaryOperation: String(first), lhs: .constrained(expression: expression), rhs: rhs)
    }

    /// Try and initialise an `Expression` where the first character is an open-bracket.
    /// - Parameter rawValue: The string containing the precedence.
    @inlinable
    init?(precedence rawValue: String) {
        guard rawValue.first == "(" else {
            return nil
        }
        var currentCount = 0
        var lastIndex: Int = 0
        for (i, c) in rawValue.enumerated() {
            if c == "(" {
                currentCount += 1
            } else if c == ")" {
                currentCount -= 1
            }
            if currentCount == 0 {
                lastIndex = i
                break
            }
        }
        guard currentCount == 0, lastIndex > 0 else { return nil }
        guard lastIndex == rawValue.index(before: rawValue.endIndex).utf16Offset(in: rawValue) else {
            let remainingStart = rawValue.index(after: String.Index(utf16Offset: lastIndex, in: rawValue))
            let remainingRaw = rawValue[remainingStart...].trimmingCharacters(in: .whitespacesAndNewlines)
            guard
                remainingRaw.count > 2,
                let first = remainingRaw.first,
                remainingRaw.hasPrefix("->") || CharacterSet.binaryLogicalOperators.contains(character: first)
            else {
                guard let language = LanguageExpression(rawValue: rawValue) else {
                    return nil
                }
                self = .language(expression: language)
                return
            }
            let lhsRaw = rawValue[...String.Index(utf16Offset: lastIndex, in: rawValue)]
                .dropFirst()
                .dropLast()
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let operand = remainingRaw[...remainingRaw.index(after: remainingRaw.startIndex)]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let rhsRaw = remainingRaw.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines)
            guard let lhs = Expression(rawValue: lhsRaw), let rhs = Expression(rawValue: rhsRaw) else {
                return nil
            }
            self.init(binaryOperation: operand, lhs: .precedence(expression: lhs), rhs: rhs)
            return
        }
        let firstIndex = rawValue.index(after: rawValue.startIndex)
        let finalIndex = rawValue.index(before: String.Index(utf16Offset: lastIndex, in: rawValue))
        guard finalIndex > firstIndex else {
            return nil
        }
        let subExpressionRaw = String(rawValue[firstIndex...finalIndex])
        guard let expression = Expression(rawValue: subExpressionRaw) else {
            return nil
        }
        self = .precedence(expression: expression)
        return
    }

    // swiftlint:enable function_body_length

    /// Try and initialise an `Expression` where the first character is a `!`.
    /// - Parameter rawValue: The expression the `not` is applied to.
    @inlinable
    init?(not rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let expression = Expression(rawValue: trimmedString) else {
            return nil
        }
        switch expression {
        case .language:
            guard
                !trimmedString.contains(
                    where: { CharacterSet.whitespacesAndNewlines.contains(character: $0) }
                )
            else {
                return nil
            }
            self = .not(expression: expression)
        default:
            self = .not(expression: expression)
        }
    }

    /// Try and create an Expression that is a logical operation.
    /// - Parameter rawValue: The `TCTL` to parse as a string.
    @inlinable
    init?(logical rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count > 4 else {
            return nil
        }
        guard
            let firstOperation = trimmedString.enumerated()
                .first(where: { index, character in
                    guard
                        index > trimmedString.startIndex.utf16Offset(in: trimmedString),
                        index
                            < trimmedString.index(before: trimmedString.endIndex)
                            .utf16Offset(in: trimmedString)
                    else {
                        return false
                    }
                    let before = trimmedString[
                        trimmedString.index(trimmedString.startIndex, offsetBy: index - 1)
                    ]
                    let after = trimmedString[
                        trimmedString.index(trimmedString.startIndex, offsetBy: index + 1)
                    ]
                    return CharacterSet.whitespacesAndNewlines.contains(character: before)
                        && CharacterSet.whitespacesAndNewlines.contains(character: after) && character == "^"
                        || character == "V"
                })
        else {
            return nil
        }
        let lhsRaw = trimmedString[
            ..<(trimmedString.index(trimmedString.startIndex, offsetBy: firstOperation.0))
        ]
        .trimmingCharacters(in: .whitespacesAndNewlines)
        let rhsRaw = trimmedString[
            trimmedString.index(trimmedString.startIndex, offsetBy: firstOperation.0 + 1)...
        ]
        .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lhs = Expression(rawValue: lhsRaw), let rhs = Expression(rawValue: rhsRaw) else {
            return nil
        }
        self.init(binaryOperation: String(firstOperation.1), lhs: lhs, rhs: rhs)
    }

    /// Create an `Expression` that is a binary operation.
    /// - Parameters:
    ///   - operation: The operation to perform as the raw TCTL symbol of that operation. Valid values are:
    /// `^`, `V`, `->`.
    ///   - lhs: The left-hand side operand.
    ///   - rhs: The right-hand side operand.
    @inlinable
    init?(binaryOperation operation: String, lhs: Expression, rhs: Expression) {
        switch operation.trimmingCharacters(in: .whitespacesAndNewlines) {
        case "^":
            self = .conjunction(lhs: lhs, rhs: rhs)
        case "V":
            self = .disjunction(lhs: lhs, rhs: rhs)
        case "->":
            self = .implies(lhs: lhs, rhs: rhs)
        default:
            return nil
        }
    }

    // swiftlint:enable cyclomatic_complexity

}
