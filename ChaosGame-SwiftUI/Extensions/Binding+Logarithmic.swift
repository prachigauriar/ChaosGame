//
//  Binding+Logarithmic.swift
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


extension Binding where Value == Double {
    /// Returns a new version of the binding that scales the value logarithmically using the specified base. That is,
    /// when getting the value, `log_b(value)` is returned; when setting it, the new value is `pow(base, newValue)`.
    ///
    /// - Parameter base: The base to use.
    func logarithmic(base: Double = 10) -> Binding<Double> {
        Binding.init(getValue: {
            log10(self.value) / log10(base)
        }, setValue: { (newValue) in
            self.value = pow(base, newValue)
        })
    }
}
