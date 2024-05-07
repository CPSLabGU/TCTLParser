// Configuration.swift
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

/// A configuration for the `TCTL` expressions within the specification.
public struct Configuration: RawRepresentable, Equatable, Hashable, Sendable, Codable {

    /// The language embedded within the `TCTL` expressions.
    public let language: Language

    /// An equivalent string that defines that parameters within this configuration. This string is present
    /// at the top of a specification file.
    @inlinable public var rawValue: String {
        "// spec:language \(language.rawValue)"
    }

    /// Creates a new configuration from it's string representation.
    /// - Parameter rawValue: The string defining this configuration. Please note that this string must only
    /// contain the configuration and no other content.
    @inlinable
    public init?(rawValue: String) {
        let rawTrimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = rawTrimmed.components(separatedBy: .newlines).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard components.allSatisfy({ $0.hasPrefix("// spec:") }) else {
            return nil
        }
        let languages: [Language] = components.compactMap {
            let spec = $0.dropFirst(8).trimmingCharacters(in: .whitespacesAndNewlines)
            guard spec.hasPrefix("language") else {
                return nil
            }
            let withoutLanguage = spec.dropFirst(8).trimmingCharacters(in: .whitespacesAndNewlines)
            return Language(rawValue: withoutLanguage)
        }
        guard languages.count == 1, let language = languages.first else {
            return nil
        }
        self.init(language: language)
    }

    /// Creates a new configuration with the given language.
    /// - Parameter language: The language within the `TCTL` expression.
    @inlinable
    public init(language: Language) {
        self.language = language
    }

}
