// Arrangement+modelInit.swift
// LLFSMGenerate
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
import JavascriptModel
import VHDLMachines
import VHDLParsing

/// Add conversion initialiser between ``ArrangementModel`` and `Arrangement`.
extension Arrangement {

    // swiftlint:disable function_body_length

    /// Create an `Arrangement` from its javascript representation.
    /// - Parameter model: The javascript model to convert.
    /// - Parameter basePath: The path of the directory containing the arrangement folder.
    @inlinable
    public init(model: ArrangementModel, basePath: URL? = nil) throws {
        let keyNames = model.machines.map(\.name)
        guard keyNames.count == Set(keyNames).count else {
            throw TransformationError.modelError(message: "Duplicate machine names in arrangement.")
        }
        let machineTuples: [(MachineInstance, MachineMapping)] = try model.machines
            .map { (reference: MachineReference) -> (MachineInstance, MachineMapping) in
                let instance = try MachineInstance(reference: reference)
                let mapping = try MachineMapping(reference: reference, basePath: basePath)
                return (instance, mapping)
            }
        guard machineTuples.count == Set(machineTuples.map { $0.0 }).count else {
            throw TransformationError.modelError(message: "Duplicate machine instances in arrangement.")
        }
        let machines = Dictionary(uniqueKeysWithValues: machineTuples)
        let externalsRaw = model.externalVariables.components(separatedBy: ";")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let externalSignals = try externalsRaw.map {
            guard let signal = PortSignal(rawValue: $0 + ";") else {
                throw TransformationError.modelError(message: "Invalid external signal \($0) in arrangement.")
            }
            return signal
        }
        let signalsRaw = model.globalVariables.components(separatedBy: ";")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let localSignals = try signalsRaw.map {
            guard let signal = LocalSignal(rawValue: $0 + ";") else {
                throw TransformationError.modelError(message: "Invalid local signal \($0) in arrangement.")
            }
            return signal
        }
        let clocks = try model.clocks.map { try Clock(model: $0) }
        let clockNames = clocks.map(\.name)
        let signalNames = localSignals.map(\.name) + externalSignals.map(\.name)
        let allNames = clockNames + signalNames
        guard
            externalSignals.count == externalsRaw.count,
            localSignals.count == signalsRaw.count,
            clocks.count == model.clocks.count,
            Set(allNames).count == allNames.count
        else {
            throw TransformationError.modelError(message: "Duplicate variable names in arrangement.")
        }
        guard
            let arrangement = Arrangement(
                mappings: machines,
                externalSignals: externalSignals,
                signals: localSignals,
                clocks: clocks
            )
        else {
            throw TransformationError.modelError(message: "Invalid arrangement model.")
        }
        self = arrangement
    }

    // swiftlint:enable function_body_length

}

/// Add init from javascript model.
extension MachineInstance {

    /// Create a `MachineInstace` from its javascript model.
    /// - Parameter reference: The ``MachineReferece`` js model to convert.
    @inlinable
    init(reference: MachineReference) throws {
        let url = URL(fileURLWithPath: reference.path, isDirectory: true)
        let nameRaw = url.lastPathComponent
        guard nameRaw.hasSuffix(".machine") else {
            throw TransformationError.parseError(
                message: "Machine paths must end with .machine: \(nameRaw)"
            )
        }
        guard let name = VariableName(rawValue: reference.name) else {
            throw TransformationError.parseError(
                message: "Invalid reference name \(reference.name) in arrangement."
            )
        }
        let machineName = String(nameRaw.dropLast(8))
        guard let type = VariableName(rawValue: machineName) else {
            throw TransformationError.parseError(
                message: "Invalid machine name \(machineName) in arrangement."
            )
        }
        self.init(name: name, type: type)
    }

}

/// Add init from js model.
extension MachineMapping {

    /// Create a `MachineMapping` from its javascript model.
    /// - Parameter reference: The ``MachineReferece`` js model to convert.
    /// - Parameter basePath: The path of the directory containing the arrangement folder.
    @inlinable
    init(reference: MachineReference, basePath: URL? = nil) throws {
        let url = URL(fileURLWithPath: reference.path, isDirectory: true, relativeTo: basePath)
            .appendingPathComponent("model.json", isDirectory: false)
        let mappings: [VHDLMachines.VariableMapping] = try reference.mappings.map {
            try VHDLMachines.VariableMapping(mapping: $0)
        }
        let data = try Data(contentsOf: url)
        let machineModel = try JSONDecoder().decode(MachineModel.self, from: data)
        let machine = try Machine(model: machineModel)
        guard let mapping = MachineMapping(machine: machine, with: mappings) else {
            throw TransformationError.parseError(message: "Invalid machine mapping in arrangement.")
        }
        self = mapping
    }

}

/// Add init from js model.
extension VHDLMachines.VariableMapping {

    /// Create a `VariableMapping` from its javascript model.
    /// - Parameter mapping: The ``VariableMapping`` js model to convert.
    @inlinable
    init(mapping: JavascriptModel.VariableMapping) throws {
        guard let source = VariableName(rawValue: mapping.source) else {
            throw TransformationError.parseError(
                message: "Invalid source variable name \(mapping.source) in arrangement."
            )
        }
        guard let destination = VariableName(rawValue: mapping.destination) else {
            throw TransformationError.parseError(
                message: "Invalid destination variable name \(mapping.destination) in arrangement."
            )
        }
        self.init(source: source, destination: destination)
    }

}
