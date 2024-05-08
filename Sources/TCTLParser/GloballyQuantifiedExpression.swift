// GloballyQuantifiedExpression.swift
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

/// An expression that is globally quantified.
/// 
/// These types of expressions apply to all branches extending from the current state.
public indirect enum GloballyQuantifiedExpression: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The expression must hold on all paths extending from the current state.
    /// 
    /// This constraint essentially requires that all paths must satisfy the `expression`.
    case always(expression: PathQuantifiedExpression)

    /// The expression must *eventually* hold on all paths extending from the current state.
    /// 
    /// This constraint essentially requires that at least one path must satisfy the `expression`.
    case eventually(expression: PathQuantifiedExpression)

    /// The equivalent `TCTL` that defines this expression.
    @inlinable public var rawValue: String {
        switch self {
        case .always(let expression):
            return "A \(expression.rawValue)"
        case .eventually(let expression):
            return "E \(expression.rawValue)"
        }
    }

    /// Create the expression from it's `TCTL` representation.
    /// - Parameter rawValue: The `TCTL` representation of the expression.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let firstChar = trimmedString.first, CharacterSet.globalQuantifiers.contains(character: firstChar)
        else {
            return nil
        }
        let remaining = String(trimmedString.dropFirst(1))
        guard
            let secondChar = remaining.first,
            CharacterSet.whitespacesAndNewlines.contains(character: secondChar),
            let expression = PathQuantifiedExpression(rawValue: remaining)
        else {
            return nil
        }
        if case .quantified = expression.expression {
            // Nested quantified expressions are invalid syntax.
            return nil
        }
        self.init(quantifier: firstChar, expression: expression)
    }

    /// Create the expression from it's quantifier and path qualified expression.
    /// - Parameters:
    ///   - quantifier: The quantifier of this expression. This valid values are `A` for always and `E` for
    /// eventually.
    ///   - expression: The expression to globally quantify.
    @inlinable
    public init?(quantifier: Character, expression: PathQuantifiedExpression) {
        switch quantifier {
        case "A":
            self = .always(expression: expression)
        case "E":
            self = .eventually(expression: expression)
        default:
            return nil
        }
    }

}
