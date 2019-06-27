//
//  CGPoint+Random.swift
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

import CoreGraphics
import Foundation


public extension CGPoint {
    /// Returns a random point in the specified rectangle.
    ///
    /// The `SystemRandomNumberGenerator` is used to generate the point.
    ///
    /// - Parameter rect: The rectangle inside which a random point is selected.
    static func random(in rect: CGRect) -> CGPoint {
        var generator = SystemRandomNumberGenerator()
        return random(in: rect, using: &generator)
    }


    /// Returns a random point in the specified rectangle.
    ///
    /// - Parameters:
    ///   - rect: The rectangle inside which a random point is selected.
    ///   - generator: The random number generator to use when generating the point.
    static func random<RNG>(in rect: CGRect, using generator: inout RNG) -> CGPoint
        where RNG : RandomNumberGenerator {
            return CGPoint(x: CGFloat.random(in: rect.minX ... rect.maxX, using: &generator),
                           y: CGFloat.random(in: rect.minY ... rect.maxY, using: &generator))
    }
}
