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


extension Slider {
    /// Creates a new `Slider` with a base-10 logarithmic scale.
    ///
    /// ## Example
    ///
    ///     @State private var frequency = 1.0
    ///
    ///     var body: some View {
    ///         Slider.withLog10Scale(value: $frequency, from: 1, through: 100)
    ///     }
    ///
    /// - Parameters:
    ///   - value: A binding to the unscaled value.
    ///   - minValue: The unscaled minimum value.
    ///   - maxValue: The unscaled maximum value.
    ///   - onEditingChanged: Documentation forthcoming.
    static func withLog10Scale(value: Binding<Double>,
                               from minValue: Double,
                               through maxValue: Double,
                               onEditingChanged: @escaping (Bool) -> Void = { _ in }) -> Slider {

        // Convert the min and max values as well
        return self.init(value: value.logarithmic(),
                         from: log10(minValue),
                         through: log10(maxValue),
                         onEditingChanged: onEditingChanged)
    }
}
