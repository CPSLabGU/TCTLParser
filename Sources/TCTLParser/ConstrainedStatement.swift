// ConstrainedStatement.swift
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

public enum ConstrainedStatement: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    case lessThan(constraint: Constraint)

    case lessThanOrEqual(constraint: Constraint)

    case greaterThan(constraint: Constraint)

    case greaterThanOrEqual(constraint: Constraint)

    case equal(constraint: Constraint)

    case notEqual(constraint: Constraint)

    public var rawValue: String {
        switch self {
        case .lessThan(let constraint):
            return "\(constraint.symbol) < \(constraint.rawValue)"
        case .lessThanOrEqual(let constraint):
            return "\(constraint.symbol) <= \(constraint.rawValue)"
        case .greaterThan(let constraint):
            return "\(constraint.symbol) > \(constraint.rawValue)"
        case .greaterThanOrEqual(let constraint):
            return "\(constraint.symbol) >= \(constraint.rawValue)"
        case .equal(let constraint):
            return "\(constraint.symbol) == \(constraint.rawValue)"
        case .notEqual(let constraint):
            return "\(constraint.symbol) != \(constraint.rawValue)"
        }
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let operation = ["<", "<=", ">", ">=", "==", "!="].first(where: { trimmedString.contains($0) })
        else {
            return nil
        }
        let components = trimmedString.components(separatedBy: operation).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard components.count == 2, let constraint = Constraint(rawValue: components[1]) else {
            return nil
        }
        self.init(symbol: components[0], operation: operation, constraint: constraint)
    }

    init?(symbol: String, operation: String, constraint: Constraint) {
        let symbolTrimmed = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        let operationTrimmed = operation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard symbolTrimmed == constraint.symbol else {
            return nil
        }
        switch operationTrimmed {
        case "<":
            self = .lessThan(constraint: constraint)
        case "<=":
            self = .lessThanOrEqual(constraint: constraint)
        case ">":
            self = .greaterThan(constraint: constraint)
        case ">=":
            self = .greaterThanOrEqual(constraint: constraint)
        case "==":
            self = .equal(constraint: constraint)
        case "!=":
            self = .notEqual(constraint: constraint)
        default:
            return nil
        }
    }

}
