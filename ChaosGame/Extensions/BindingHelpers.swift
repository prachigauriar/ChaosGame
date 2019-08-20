//
//  BindingHelpers.swift
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


public extension Binding where Value == Double {
    /// Returns a new version of the binding that scales the value logarithmically using the specified base. That is,
    /// when getting the value, `log_b(value)` is returned; when setting it, the new value is `pow(base, newValue)`.
    ///
    /// - Parameter base: The base to use.
    func logarithmic(base: Double = 10) -> Binding<Double> {
        Binding(get: {
            log10(self.wrappedValue) / log10(base)
        }, set: { (newValue) in
            self.wrappedValue = pow(base, newValue)
        })
    }


    /// Returns a new version of the binding that rounds the value using the specified rounding rule.
    ///
    /// - Parameter rule: The rounding rule to use.
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Binding<Double> {
        Binding(get: {
            self.wrappedValue.rounded(rule)
        }, set: { (newValue) in
            self.wrappedValue = newValue.rounded(rule)
        })
    }


    /// Returns a new version of the binding that converts the value to an `Int`.
    func asInt() -> Binding<Int> {
        Binding<Int>(get: {
            Int(self.wrappedValue)
        }, set: { (newValue) in
            self.wrappedValue = Double(newValue)
        })
    }
    
    
    /// Returns a new version of the binding that converts the value to an `NSNumber`.
    func asNSNumber() -> Binding<NSNumber> {
        return Binding<NSNumber>(get: {
            NSNumber(value: self.wrappedValue)
        }, set: {
            self.wrappedValue = $0.doubleValue
        })
    }
}


public extension Binding where Value == Int {
    /// Returns a new version of the binding that converts the value to a `Double`.
    func asDouble() -> Binding<Double> {
        Binding<Double>(get: { () -> Double in
            Double(self.wrappedValue)
        }, set: { (newValue) in
            self.wrappedValue = Int(newValue)
        })
    }
}
