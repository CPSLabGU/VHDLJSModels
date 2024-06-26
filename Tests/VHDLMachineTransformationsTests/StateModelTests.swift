// StateModelTests.swift
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

import JavascriptModel
import VHDLMachines
@testable import VHDLMachineTransformations
import VHDLParsing
import XCTest

/// Test class for ``StateModel`` extensions.
final class StateModelTests: XCTestCase {

    /// A layout of the state.
    let layout = StateLayout(position: Point2D(x: 10, y: 20), dimensions: Point2D(x: 200, y: 100))

    // swiftlint:disable force_unwrapping

    /// A variable called `x`.
    let x = VariableName(rawValue: "x")!

    /// A variable called `y`.
    let y = VariableName(rawValue: "y")!

    /// A state to convert.
    lazy var state = State(
        name: VariableName(rawValue: "state1")!,
        actions: [
            VariableName(rawValue: "OnEntry")!: .statement(
                statement: .assignment(
                    name: .variable(reference: .variable(name: x)),
                    value: .literal(value: .bit(value: .high))
                )
            ),
            VariableName(rawValue: "OnExit")!: .statement(
                statement: .assignment(
                    name: .variable(reference: .variable(name: y)),
                    value: .literal(value: .bit(value: .low))
                )
            ),
            VariableName(rawValue: "Internal")!: .statement(
                statement: .assignment(
                    name: .variable(reference: .variable(name: x)),
                    value: .literal(value: .bit(value: .low))
                )
            )
        ],
        signals: [
            LocalSignal(type: .stdLogic, name: x),
            LocalSignal(
                type: .stdLogic, name: y, defaultValue: .literal(value: .bit(value: .high)), comment: nil
            )
        ],
        externalVariables: [VariableName(rawValue: "extX")!, VariableName(rawValue: "extY")!]
    )

    override func setUp() {
        state = State(
            name: VariableName(rawValue: "state1")!,
            actions: [
                VariableName(rawValue: "OnEntry")!: .statement(
                    statement: .assignment(
                        name: .variable(reference: .variable(name: x)),
                        value: .literal(value: .bit(value: .high))
                    )
                ),
                VariableName(rawValue: "OnExit")!: .statement(
                    statement: .assignment(
                        name: .variable(reference: .variable(name: y)),
                        value: .literal(value: .bit(value: .low))
                    )
                ),
                VariableName(rawValue: "Internal")!: .statement(
                    statement: .assignment(
                        name: .variable(reference: .variable(name: x)),
                        value: .literal(value: .bit(value: .low))
                    )
                )
            ],
            signals: [
                LocalSignal(type: .stdLogic, name: x),
                LocalSignal(
                    type: .stdLogic, name: y, defaultValue: .literal(value: .bit(value: .high)), comment: nil
                )
            ],
            externalVariables: [VariableName(rawValue: "extX")!, VariableName(rawValue: "extY")!]
        )
    }

    // swiftlint:enable force_unwrapping

    /// Test conversion from state.
    func testInit() {
        let model = StateModel(state: state, layout: layout)
        XCTAssertEqual(model.name, "state1")
        XCTAssertEqual(model.variables, "signal x: std_logic;\nsignal y: std_logic := '1';")
        XCTAssertEqual(model.externalVariables, "extX\nextY")
        XCTAssertEqual(model.actions, [
            ActionModel(name: "Internal", code: "x <= '0';"),
            ActionModel(name: "OnEntry", code: "x <= '1';"),
            ActionModel(name: "OnExit", code: "y <= '0';")
        ])
        XCTAssertEqual(model.layout, layout)
    }

}
