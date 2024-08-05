// Specification.swift
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

/// A `Specification` is a set of requirements that must hold `true`.
public struct Specification: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The configuration of this specification.
    /// 
    /// The configuration customises the specification of the `TCTL` formulae. For example, the formulae may
    /// contains primitives that are expresses using a targetted language, e.g. `VHDL`.
    public let configuration: Configuration

    /// The requirements specified in `TCTL` formulas.
    public let requirements: [Expression]

    /// The equivalent `String` representation defining this `Specification`. Please note that this `rawValue`
    /// does not include the comments that may have been present in the original representation.
    @inlinable public var rawValue: String {
        """
        \(configuration.rawValue)

        \(requirements.map(\.rawValue).joined(separator: "\n\n"))

        """
    }

    /// Creates a new `Specification` from it's `rawValue` representation.
    /// - Parameter rawValue: The `String` representation of the `Specification`.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = trimmedString.components(separatedBy: .newlines).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard !components.isEmpty, components[0].hasPrefix("//") else {
            return nil
        }
        guard let firstIndex = components.firstIndex(where: { !$0.hasPrefix("//") }) else {
            guard let configuration = Configuration(rawValue: trimmedString) else {
                return nil
            }
            self.init(configuration: configuration, requirements: [])
            return
        }
        let configurationRaw = components[..<firstIndex].joined(separator: "\n")
        let requirementsWithoutComments = components[firstIndex...].compactMap {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("--")
                ? nil
                : $0.components(separatedBy: "--").first
        }
        let requirementsRaw = requirementsWithoutComments.joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(configurationRaw: configurationRaw, requirementsRaw: requirementsRaw)
    }

    /// Creates a new `Specification` from it's string representations of the `configuration` and
    /// `requirements`.
    /// - Parameters:
    ///   - configurationRaw: The `rawValue` of the ``Configuration``.
    ///   - requirementsRaw: The `rawValue` of all ``GloballyQuantifiedExpression`` requirements.
    @inlinable
    init?(configurationRaw: String, requirementsRaw: String) {
        guard let configuration = Configuration(rawValue: configurationRaw) else {
            return nil
        }
        let requirementsComponents = requirementsRaw.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let requirements = requirementsComponents.compactMap(Expression.init(rawValue:))
        guard requirements.count == requirementsComponents.count else {
            return nil
        }
        self.init(configuration: configuration, requirements: requirements)
    }

    /// Creates a new `Specification` from it's stored properties.
    /// - Parameters:
    ///   - configuration: The configuration of this specification.
    ///   - requirements: The requirements specified in `TCTL` formulas.
    @inlinable
    public init(configuration: Configuration, requirements: [Expression]) {
        self.configuration = configuration
        self.requirements = requirements
    }

}
