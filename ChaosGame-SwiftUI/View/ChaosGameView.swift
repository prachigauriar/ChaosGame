//
//  ChaosGameView.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 6/11/2019.
//  Copyright © 2019 Prachi Gauriar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Combine
import Foundation
import SceneKit
import SwiftUI


struct ChaosGameView : View {
    @ObjectBinding private var viewModel = ChaosGameViewModel()
    @State private var settingsEditingContext = EditingContext(ChaosGameSettings())


    var body: some View {
        VStack {
            VStack {
                Slider.withLog10Scale(value: $viewModel.frequency, from: 1, through: 60_000)

                Text("Iteration Frequency: \(viewModel.formattedFrequency)")
                    .font(.subheadline)

                HStack(spacing : 20) {
                    Button(action: { self.resetGame() }) {
                        Image(systemName: "backward.end.alt")
                            .imageScale(.large)
                    }

                    Button(action: { self.viewModel.isRunning.toggle() }) {
                        Image(systemName: viewModel.isRunning ? "pause" : "play")
                            .imageScale(.large)
                    }

                    Button(action: { self.settingsEditingContext.isEditing = true }) {
                        Image(systemName: "gear")
                    }.disabled(viewModel.isRunning)
                }.padding()
            }.padding()

            PlotView(scene: $viewModel.scene, iterationCount: $viewModel.iterationCount)
        }.presentation(settingsEditingContext.isEditing ? settingsModal : nil)
    }


    var settingsModal: Modal {
        let editSettingsView = EditSettingsView(context: $settingsEditingContext) {
            self.resetGame()
        }

        return Modal(editSettingsView) {
            self.settingsEditingContext.discard()
            self.settingsEditingContext.isEditing = false
        }
    }


    private func resetGame() {
        viewModel.reset(with: self.settingsEditingContext.value)
    }
}
