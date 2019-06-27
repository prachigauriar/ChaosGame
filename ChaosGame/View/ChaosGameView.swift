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


/// `ChaosGameView` is the primary view component in the ChaosGame app. It provides controls and a plot view so that you
/// can control a `ChaosGamePlotter` and view its points.
public struct ChaosGameView : View {
    /// A formatter for formatting the the rate under the slider.
    private static let rateFormatter = MeasurementFormatter()

    /// The plotter that is used as a primary model object.
    @ObjectBinding private var plotter = ChaosGamePlotter()

    /// The rate at which the ChaosGamePlotter plots points. This is used to store the value of the slider. However, the
    /// value is only written to the plotter’s rate when the slider is done changing the value. This is to limit the
    /// amount of
    @State private var rate: Double = 1.0

    /// The editing context for editing the plotter’s settings.
    @State private var settingsEditingContext = EditingContext(ChaosGameSettings())


    public var body: some View {
        VStack {
            VStack {
                Slider.withLog10Scale(value: $rate.rounded(.towardZero), from: 1, through: 60_000) { (_) in
                    self.plotter.rate = Int(self.rate)
                }

                Text("Rate: \(formattedRate)")
                    .font(.subheadline)

                HStack(spacing : 20) {
                    Button(action: resetGame) {
                        Image(systemName: "backward.end.alt")
                            .imageScale(.large)
                    }

                    Button(action: toggleRunningState) {
                        Image(systemName: plotter.isRunning ? "pause" : "play")
                            .imageScale(.large)
                    }

                    Button(action: startEditingSettings) {
                        Image(systemName: "gear")
                    }.disabled(plotter.isRunning)
                }.padding()
            }.padding()

            PlotView(scene: plotter.scene, pointCount: plotter.pointCount)
        }.presentation(settingsEditingContext.isEditing ? editSettingsModal : nil)
    }


    /// Returns the current rate formatted in Hz.
    private var formattedRate: String {
        return type(of: self).rateFormatter.string(from: Measurement(value: rate, unit: UnitFrequency.hertz))
    }


    /// Returns a modal containing an `EditSettings` view.
    private var editSettingsModal: Modal {
        let editSettingsView = EditSettingsView(context: $settingsEditingContext) {
            self.resetGame()
        }

        return Modal(editSettingsView) {
            self.settingsEditingContext.discard()
            self.settingsEditingContext.isEditing = false
        }
    }


    // MARK: - Actions

    /// Resets the plotter with the current Chaos Game settings.
    private func resetGame() {
        plotter.reset(with: self.settingsEditingContext.value)
    }


    /// Toggles whether the plotter is running or not.
    private func toggleRunningState() {
        plotter.isRunning.toggle()
    }


    /// Starts editing settings. This sets `settingEditingContext.isEditing` to `true`, which in turn will result in the
    /// `editSettingsModal` to be presented.
    private func startEditingSettings() {
        settingsEditingContext.isEditing = true
    }
}
