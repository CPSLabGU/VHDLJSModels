// Machine+jsInit.swift
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

/// Add conversion from a `MachineModel` to a `Machine`.
extension Machine {

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length

    /// Create a new machine from a javscript model located at an optional given path.
    /// - Parameters:
    ///   - model: The model representing this machine.
    ///   - path: The path where the machine is located.
    @inlinable
    public init(model: MachineModel) throws {
        let actionNames = Set(["OnEntry", "OnExit", "Internal"])
            .union(model.states.flatMap { $0.actions.map(\.name) })
        let variableNames = try actionNames.map {
            guard let name = VariableName(rawValue: $0) else {
                throw TransformationError.parseError(message: "Invalid action name: \($0)")
            }
            return name
        }
        let actionVariableNames = Set(variableNames).sorted()
        let getStatements: (String) -> [String] = {
            $0.components(separatedBy: ";")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { $0 + ";" }
        }
        let includes = getStatements(model.includes)
        let parsedIncludes = try includes.map {
            guard let include = Include(rawValue: $0) else {
                throw TransformationError.parseError(message: "Invalid include: \($0)")
            }
            return include
        }
        let machineSignalsRaw = getStatements(model.machineVariables)
        let machineSignals = try machineSignalsRaw.map {
            guard let signal = LocalSignal(rawValue: $0) else {
                throw TransformationError.parseError(message: "Invalid machine variable: \($0)")
            }
            return signal
        }
        let externalsRaw = getStatements(model.externalVariables)
        let externalSignals = try externalsRaw.map {
            guard let signal = PortSignal(rawValue: $0) else {
                throw TransformationError.parseError(message: "Invalid external variable: \($0)")
            }
            return signal
        }
        guard !model.clocks.isEmpty else {
            throw TransformationError.modelError(
                message: "At least one clock must be defined in each machine."
            )
        }
        let clocks = try model.clocks.map(Clock.init(model:))
        guard !model.states.isEmpty else {
            throw TransformationError.modelError(
                message: "At least one state must be defined in each machine."
            )
        }
        let states = try model.states.map { try State(model: $0) }
        let transitions = try model.transitions.map { try Transition(model: $0, states: states) }
        guard
            let initialName = VariableName(rawValue: model.initialState),
            let initialState = states.firstIndex(where: { $0.name == initialName })
        else {
            throw TransformationError.parseError(message: "Invalid initial state: \(model.initialState)")
        }
        var suspendedIndex: Int?
        if let suspendedState = model.suspendedState {
            guard
                let suspendedName = VariableName(rawValue: suspendedState),
                let index = states.firstIndex(where: { $0.name == suspendedName })
            else {
                throw TransformationError.parseError(message: "Invalid suspended state: \(suspendedState)")
            }
            suspendedIndex = index
        }
        let stateNames: [VariableName] =
            states.map(\.name) + states.flatMap { $0.signals.map(\.name) }
            + actionVariableNames
        let signalNames: [VariableName] =
            externalSignals.map(\.name) + machineSignals.map(\.name)
            + clocks.map(\.name)
        let allNames: [VariableName] = stateNames + signalNames
        // Check for duplicate names.
        guard Set(allNames).count == allNames.count else {
            let duplicates =
                allNames.reduce(into: [VariableName: Int]()) { counts, name in
                    counts[name, default: 0] += 1
                }
                .filter { $0.value > 1 }
                .map(\.key)
            throw TransformationError.modelError(
                message: "Duplicate names found: \(duplicates.map(\.rawValue).joined(separator: ", "))"
            )
        }
        self.init(
            actions: actionVariableNames,
            includes: parsedIncludes,
            externalSignals: externalSignals,
            clocks: clocks,
            drivingClock: 0,
            machineSignals: machineSignals,
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: states,
            transitions: transitions,
            initialState: initialState,
            suspendedState: suspendedIndex,
            architectureHead: nil,
            architectureBody: nil
        )
    }

    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

}
