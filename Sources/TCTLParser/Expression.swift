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
    case implies(lhs: Expression, rhs: SubExpression)

    /// A `TCTL` expression that contains `VHDL` code.
    case vhdl(expression: VHDLExpression)

    /// The equivalent `TCTL` expression as a string.
    @inlinable public var rawValue: String {
        switch self {
        case .implies(let lhs, let rhs):
            return "\(lhs.rawValue) -> \(rhs.rawValue)"
        case .vhdl(let expression):
            return expression.rawValue
        }
    }

    /// Create the expression from the `TCTL` expression as a string.
    /// - Parameter rawValue: The `TCTL` expression as a string.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let impliesIndex = trimmedString.range(of: "->") else {
            guard let expression = VHDLExpression(rawValue: trimmedString) else {
                return nil
            }
            self = .vhdl(expression: expression)
            return
        }
        let lhsRaw = trimmedString[..<impliesIndex.lowerBound]
        guard impliesIndex.upperBound < trimmedString.index(before: trimmedString.endIndex) else {
            return nil
        }
        let rhsRaw = trimmedString[trimmedString.index(after: impliesIndex.upperBound)...]
        guard
            let lhs = Expression(rawValue: String(lhsRaw)), let rhs = SubExpression(rawValue: String(rhsRaw))
        else {
            return nil
        }
        self = .implies(lhs: lhs, rhs: rhs)
    }

}
