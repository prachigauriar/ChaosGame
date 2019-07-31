//
//  Slider+Logarithmic.swift
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


public extension Slider where ValueLabel == EmptyView {
    /// Creates a new `Slider` with a base-10 logarithmic scale.
    ///
    /// ## Example
    ///
    ///     @State private var frequency = 1.0
    ///
    ///     var body: some View {
    ///         Slider.withLog10Scale(value: $frequency, in: 1 ... 100) { Text("Frequency") }
    ///     }
    ///
    /// - Parameters:
    ///   - value: A binding to the unscaled value.
    ///   - bounds: The unscaled bounds for the value.
    ///   - onEditingChanged: Documentation forthcoming.
    ///   - label: The slider’s label.
    static func withLog10Scale(value: Binding<Double>,
                               in bounds: ClosedRange<Double>,
                               onEditingChanged: @escaping (Bool) -> Void = { _ in },
                               label: () -> Label) -> Slider {
        return self.init(value: value.logarithmic(),
                         in: log10(bounds.lowerBound) ... log10(bounds.upperBound),
                         onEditingChanged: onEditingChanged,
                         label: label)
    }
}
