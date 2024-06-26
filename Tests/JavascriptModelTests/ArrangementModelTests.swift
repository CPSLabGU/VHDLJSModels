// ArrangementModelTests.swift
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
@testable import JavascriptModel
import XCTest

/// Test class for ``ArrangementModel``.
final class ArrangementModelTests: XCTestCase {

    /// The clocks in the arrangement.
    let clocks = [
        ClockModel(name: "clk", frequency: "50 MHz"),
        ClockModel(name: "clk2", frequency: "100 MHz")
    ]

    /// The external variables in the arrangement.
    let externalVariables = """
    x: in std_logic;
    y: out std_logic;
    """

    /// The global variables in the arrangement.
    let globalVariables = """
    signal z: std_logic;
    """

    /// The machines in the arrangement.
    let machines = [
        MachineReference(name: "machine0", path: "path/to/machine0.machine", mappings: [
            VariableMapping(source: "x", destination: "machine0_x"),
            VariableMapping(source: "y", destination: "machine0_y"),
            VariableMapping(source: "clk", destination: "clk")
        ]),
        MachineReference(name: "machine1", path: "path/to/machine1.machine", mappings: [
            VariableMapping(source: "z", destination: "machine1_z"),
            VariableMapping(source: "clk2", destination: "clk")
        ])
    ]

    /// The arrangement under test.
    lazy var arrangement = ArrangementModel(
        clocks: clocks,
        externalVariables: externalVariables,
        machines: machines,
        globalVariables: globalVariables
    )

    /// Initialise the arrangement before every test.
    override func setUp() {
        arrangement = ArrangementModel(
            clocks: clocks,
            externalVariables: externalVariables,
            machines: machines,
            globalVariables: globalVariables
        )
    }

    /// Test that the initialiser sets the stored properties correctly.
    func testInit() {
        XCTAssertEqual(arrangement.clocks, clocks)
        XCTAssertEqual(arrangement.externalVariables, externalVariables)
        XCTAssertEqual(arrangement.machines, machines)
        XCTAssertEqual(arrangement.globalVariables, globalVariables)
    }

    /// Test that the setters mutate the stored properties correctly.
    func testSetters() {
        let newClocks = [ClockModel(name: "clk3", frequency: "20 MHz")]
        arrangement.clocks = newClocks
        XCTAssertEqual(arrangement.clocks, newClocks)
        XCTAssertEqual(arrangement.externalVariables, externalVariables)
        XCTAssertEqual(arrangement.machines, machines)
        XCTAssertEqual(arrangement.globalVariables, globalVariables)
        let newExternalVariables = """
        x2: in std_logic;
        """
        arrangement.externalVariables = newExternalVariables
        XCTAssertEqual(arrangement.clocks, newClocks)
        XCTAssertEqual(arrangement.externalVariables, newExternalVariables)
        XCTAssertEqual(arrangement.machines, machines)
        XCTAssertEqual(arrangement.globalVariables, globalVariables)
        let newMachines = [
            MachineReference(name: "machine2", path: "path/to/machine2.machine", mappings: [
                VariableMapping(source: "x2", destination: "machine2_x2")
            ])
        ]
        arrangement.machines = newMachines
        XCTAssertEqual(arrangement.clocks, newClocks)
        XCTAssertEqual(arrangement.externalVariables, newExternalVariables)
        XCTAssertEqual(arrangement.machines, newMachines)
        XCTAssertEqual(arrangement.globalVariables, globalVariables)
        let newGlobalVariables = """
        signal z2: std_logic;
        """
        arrangement.globalVariables = newGlobalVariables
        XCTAssertEqual(arrangement.clocks, newClocks)
        XCTAssertEqual(arrangement.externalVariables, newExternalVariables)
        XCTAssertEqual(arrangement.machines, newMachines)
        XCTAssertEqual(arrangement.globalVariables, newGlobalVariables)
    }

    // func testPrintModel() throws {
    //     let arrangement = ArrangementModel(
    //         clocks: [ClockModel(name: "clk", frequency: "125 MHz")],
    //         externalVariables: """
    //         sw: in std_logic;
    //         led1: out std_logic;
    //         led2: out std_logic;
    //         """,
    //         machines: [
    //             MachineReference(
    //                 name: "LEDBlinker",
    //                 path: "LEDBlinker.machine",
    //                 mappings: [
    //                     VariableMapping(source: "clk", destination: "clk"),
    //                     VariableMapping(source: "sw", destination: "sw"),
    //                     VariableMapping(source: "led1", destination: "led")
    //                 ]
    //             ),
    //             MachineReference(
    //                 name: "LEDBlinker",
    //                 path: "LEDBlinker.machine",
    //                 mappings: [
    //                     VariableMapping(source: "clk", destination: "clk"),
    //                     VariableMapping(source: "sw", destination: "sw"),
    //                     VariableMapping(source: "led2", destination: "led")
    //                 ]
    //             )
    //         ],
    //         globalVariables: ""
    //     )
    //     let encoder = JSONEncoder()
    //     let jsonData = try encoder.encode(arrangement)
    //     let jsonString = String(data: jsonData, encoding: .utf8)!
    //     print(jsonString)
    //     fflush(stdout)
    //     print("\n\n\n\n")
    //     fflush(stdout)
    //     let machineModel = MachineModel(
    //         states: [
    //             StateModel(
    //                 name: "Initial",
    //                 variables: "",
    //                 externalVariables: "",
    //                 actions: [
    //                     ActionModel(name: "Internal", code: ""),
    //                     ActionModel(name: "OnEntry", code: ""),
    //                     ActionModel(name: "OnExit", code: "")
    //                 ],
    //                 layout: StateLayout(
    //                     position: Point2D(x: 100.0, y: 100.0), dimensions: Point2D(x: 100.0, y: 50.0)
    //                 )
    //             ),
    //             StateModel(
    //                 name: "LightOn",
    //                 variables: "",
    //                 externalVariables: "sw\nled",
    //                 actions: [
    //                     ActionModel(name: "Internal", code: "led <= '1';"),
    //                     ActionModel(name: "OnEntry", code: "led <= '1';"),
    //                     ActionModel(name: "OnExit", code: "")
    //                 ],
    //                 layout: StateLayout(
    //                     position: Point2D(x: 100.0, y: 200.0), dimensions: Point2D(x: 100.0, y: 50.0)
    //                 )
    //             ),
    //             StateModel(
    //                 name: "LightOff",
    //                 variables: "",
    //                 externalVariables: "sw\nled",
    //                 actions: [
    //                     ActionModel(name: "Internal", code: "led <= '0';"),
    //                     ActionModel(name: "OnEntry", code: "led <= '0';"),
    //                     ActionModel(name: "OnExit", code: "")
    //                 ],
    //                 layout: StateLayout(
    //                     position: Point2D(x: 300.0, y: 200.0), dimensions: Point2D(x: 100.0, y: 50.0)
    //                 )
    //             )
    //         ],
    //         externalVariables: """
    //         sw: in std_logic;
    //         led: out std_logic;
    //         """,
    //         machineVariables: "",
    //         includes: """
    //         library IEEE;
    //         use IEEE.std_logic_1164.all;
    //         """,
    //         transitions: [
    //             TransitionModel(
    //                 source: "Initial",
    //                 target: "LightOff",
    //                 condition: "true",
    //                 layout: TransitionLayout(path: BezierPath(
    //                     source: Point2D(x: 180.0, y: 150.0),
    //                     target: Point2D(x: 350.0, y: 200.0),
    //                     control0: Point2D(x: 222.5, y: 165.0),
    //                     control1: Point2D(x: 307.5, y: 190.0)
    //                 ))
    //             ),
    //             TransitionModel(
    //                 source: "LightOn",
    //                 target: "LightOff",
    //                 condition: "sw = '0'",
    //                 layout: TransitionLayout(path: BezierPath(
    //                     source: Point2D(x: 200.0, y: 215.0),
    //                     target: Point2D(x: 300.0, y: 215.0),
    //                     control0: Point2D(x: 235.0, y: 215.0),
    //                     control1: Point2D(x: 270.0, y: 215.0)
    //                 ))
    //             ),
    //             TransitionModel(
    //                 source: "LightOff",
    //                 target: "LightOn",
    //                 condition: "sw = '1'",
    //                 layout: TransitionLayout(path: BezierPath(
    //                     source: Point2D(x: 300, y: 235.0),
    //                     target: Point2D(x: 200.0, y: 235.0),
    //                     control0: Point2D(x: 270.0, y: 235.0),
    //                     control1: Point2D(x: 235.0, y: 235.0)
    //                 ))
    //             )
    //         ],
    //         initialState: "Initial",
    //         suspendedState: nil,
    //         clocks: [ClockModel(name: "clk", frequency: "125 MHz")]
    //     )
    //     let machineData = try encoder.encode(machineModel)
    //     let machineString = String(data: machineData, encoding: .utf8)!
    //     print(machineString)
    //     fflush(stdout)
    // }

}
