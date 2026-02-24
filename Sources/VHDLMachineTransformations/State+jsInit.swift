// State+jsInit.swift
// VHDLMachineTransformations
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
// 

import Foundation
import JavascriptModel
import VHDLMachines
import VHDLParsing

/// Add init from ``StateModel``.
extension State {

    /// Initialise a state from its Javascript model.
    /// - Parameter model: The javascript model that represents this state.
    /// - SeeAlso: ``StateModel``.
    @inlinable
    public init(model: StateModel) throws {
        guard let name = VariableName(rawValue: model.name) else {
            throw TransformationError.parseError(message: "Invalid state name: \(model.name)")
        }
        let validActions = model.actions.filter {
            !$0.code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        let actionTuples = try validActions.map {
            guard let name = VariableName(rawValue: $0.name) else {
                throw TransformationError.parseError(
                    message: "Invalid action name \($0.name) in state \(model.name)"
                )
            }
            guard let code = SynchronousBlock(rawValue: $0.code) else {
                throw TransformationError.parseError(
                    message: "Could not parse \($0.name) action code in state \(model.name)"
                )
            }
            return (name, code)
        }
        guard Set(actionTuples.map(\.0)).count == actionTuples.count else {
            throw TransformationError.modelError(message: "Duplicate actions found in \(model.name) state.")
        }
        let actions = Dictionary(uniqueKeysWithValues: actionTuples)
        let signalsRaw = model.variables.components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0 + ";" }
        let signalsParsed = try signalsRaw.map {
            guard let signal = LocalSignal(rawValue: $0) else {
                throw TransformationError.parseError(
                    message: "Cannot parse state variable declaration: \($0)"
                )
            }
            return signal
        }
        let externalsRaw = model.externalVariables.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let externalVariables = try externalsRaw.map {
            guard let name = VariableName(rawValue: $0) else {
                throw TransformationError.parseError(
                    message: "Invalid external variable name \($0) in the \(model.name) state's access list."
                )
            }
            return name
        }
        self.init(
            name: name,
            actions: actions,
            signals: signalsParsed,
            externalVariables: externalVariables
        )
    }

}
