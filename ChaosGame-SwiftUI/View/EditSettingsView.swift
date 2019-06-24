//
//  EditSettingsView.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 6/24/2019.
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

import Foundation
import SwiftUI


struct EditSettingsView : View {
    @Binding var context: EditingContext<ChaosGameSettings>
    private let onSave: () -> Void


    init(context: Binding<EditingContext<ChaosGameSettings>>, onSave: @escaping () -> Void = { }) {
        $context = context
        self.onSave = onSave
    }

    
    private static let distanceFactorFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()


    var body: some View {
        NavigationView {
            Form {
                // Vertices
                Stepper(value: $context.draft.polygonVertexCount, in: 3 ... 20) {
                    Text("Vertices: \(context.draft.polygonVertexCount)")
                }

                // Distance Factor
                Stepper(value: $context.draft.distanceFactor, in: 0.05 ... 0.95, step: 0.05) {
                    Text("Distance Factor: \(EditSettingsView.distanceFactorFormatter.string(from: NSNumber(value: context.draft.distanceFactor))!)")
                }

                // Vertex Selection Strategy
                Picker(selection: $context.draft.vertexSelectionStrategy, label: Text("Vertex Selection Strategy")) {
                    Text("Random").tag(VertexSelectionStrategy.random)
                    Text("Non-Repeating").tag(VertexSelectionStrategy.nonRepeating)
                    Text("Not One Place Away").tag(VertexSelectionStrategy.notOneCounterClockwisePlaceAway)
                }
            }.navigationBarTitle(Text("Settings"))
                .navigationBarItems(leading: Button(action: cancel) { Text("Cancel") },
                                    trailing: Button(action: save) { Text("Save") })
        }
    }


    private func cancel() {
        context.discard()
        context.isEditing = false
    }


    private func save() {
        context.save()
        self.onSave()
        context.isEditing = false
    }
}
