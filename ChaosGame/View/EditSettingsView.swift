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


/// The `EditSettingsView` represents a view for editing Chaos Game settings. Its primary model is an `EditingContext`
/// containing an instance of `ChaosGameSettings`. It provides views for modifying the number of vertices for the
/// Chaos Game’s polygon, distance factor, and polygon vertex selection strategy. Saving and Canceling are explicit
/// actions.
public struct EditSettingsView : View {
    /// The editing context used as a model for this view.
    @ObservedObject private var context: EditingContext<ChaosGameSettings>

    /// Stores the distance factor that is being edited by the text field.
    @State private var distanceFactor: Double
    
    /// A closure to execute when the user presses the Save button.
    private let onSave: () -> Void


    /// Creates a new `EditSettingsView` with the specified context and `onSave` closure.
    ///
    /// - Parameters:
    ///   - context: A binding to the editing context for the view.
    ///   - onSave: A closure to execute when the user presses the Save button.
    public init(context: ObservedObject<EditingContext<ChaosGameSettings>>, onSave: @escaping () -> Void = { }) {
        self._context = context
        self._distanceFactor = State<Double>(initialValue: context.wrappedValue.draft.distanceFactor)
        self.onSave = onSave
    }
    
    
    public var body: some View {
        NavigationView {
            Form {
                // Vertices
                Stepper(value: $context.draft.polygonVertexCount, in: 3 ... 20) {
                    Text("Vertices: \(context.draft.polygonVertexCount)")
                }

                // Distance Factor
                HStack {
                    Text("Distance Factor:")
                    TextField("", value: $distanceFactor.asNSNumber(),
                              formatter: type(of: self).distanceFactorFormatter, onCommit: {
                                self.context.draft.distanceFactor = self.distanceFactor
                    })
                        .multilineTextAlignment(.trailing)
                }
                
                // Vertex Selection Strategy
                Picker(selection: $context.draft.vertexSelectionStrategy, label: Text("Vertex Selection Strategy")) {
                    ForEach(ChaosGameSettings.VertexSelectionStrategy.allCases, id: \.self) {
                        Text($0.localizedStringKey).tag($0)
                    }
                }
            }.navigationBarTitle(Text("Settings"))
                .navigationBarItems(leading: Button(action: cancel) { Text("Cancel") },
                                    trailing: Button(action: save) { Text("Save") })
        }
    }


    /// A formatter for formatting the distance factor.
    private static let distanceFactorFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.isPartialStringValidationEnabled = true
        formatter.isLenient = true
        return formatter
    }()


    /// Returns the distance factor formatted as a String.
    private var formattedDistanceFactor: String {
        return type(of: self).distanceFactorFormatter.string(from: NSNumber(value: context.draft.distanceFactor))!
    }


    // MARK: - Actions

    /// Cancels the editing process by discarding the edits and setting `context.isEditing` to `false`.
    private func cancel() {
        context.discard()
        context.isEditing = false
    }


    /// Saves changes by saving the context, invoking the `onSave` closure, and setting `context.isEditing` to `false`.
    private func save() {
        context.save()
        onSave()
        context.isEditing = false
    }
}


// MARK: -

private extension ChaosGameSettings.VertexSelectionStrategy {
    /// The localized string key representing the strategy.
    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .random:
            return LocalizedStringKey("Random")
        case .nonRepeating:
            return LocalizedStringKey("Non-Repeating")
        case .notOneCounterClockwisePlaceAway:
            return LocalizedStringKey("Not One Place Away")
        case .notTwoCounterClockwisePlacesAway:
            return LocalizedStringKey("Not Two Places Away")
        case .notAdjacentToPreviousIfTwoPreviousWereIdentical:
            return LocalizedStringKey("Not Adjacent If Two Previous Were Identical")
        }
    }
}
