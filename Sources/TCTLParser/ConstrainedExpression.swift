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

public struct ConstrainedExpression: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    public let expression: Expression

    public let constraints: [ConstrainedStatement]

    public var rawValue: String {
        "{\(expression.rawValue)}_{\(constraints.map(\.rawValue).joined(separator: ", "))}"
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.hasPrefix("{") else {
            return nil
        }
        let remaining = trimmedString.dropFirst()
        var terminatingIndex = 0
        var bracketCount = 1
        for (index, character) in remaining.enumerated() {
            if character == "{" {
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
        guard let expression = Expression(rawValue: String(expressionRaw)) else {
            return nil
        }
        guard remaining.count > terminatingIndex + 1 else {
            return nil
        }
        let constraintsSection = remaining[
            remaining.index(remaining.startIndex, offsetBy: terminatingIndex + 1)...
        ]
        guard constraintsSection.hasPrefix("_{"), constraintsSection.hasSuffix("}") else {
            return nil
        }
        let constraintsRaw = constraintsSection.dropFirst(2).dropLast()
        let constraintsComponents = constraintsRaw.components(separatedBy: ",")
        let constraints = constraintsComponents.compactMap {
            ConstrainedStatement(rawValue: $0)
        }
        guard constraints.count == constraintsComponents.count, !constraints.isEmpty else {
            return nil
        }
        self.init(expression: expression, constraints: constraints)
    }

    public init(expression: Expression, constraints: [ConstrainedStatement]) {
        guard !constraints.isEmpty else {
            fatalError("Constraints cannot be empty!")
        }
        self.expression = expression
        self.constraints = constraints
    }

}
