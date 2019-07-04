//
//  ChaosGameSequence.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/27/2017.
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


/// A `ChaosGameSequence` provides an infinite sequence of points generated using the [Chaos Game][1] algorithm.
///
/// Because of the random nature of the Chaos Game, two instances with identical initial conditions will almost
/// certainly result in different sequences of points. Thus each time you iterate through the same `ChaosGameSequence`,
/// you will get a different set of points.
///
/// [1]: https://en.wikipedia.org/wiki/Chaos_game
public struct ChaosGameSequence : Sequence {
    /// The initial point with which to start the algorithm.
    public let initialPoint: CGPoint

    /// The vertex selector to use when selecting a vertex to move towards.
    public private(set) var vertexSelector: PolygonVertexSelector

    /// The percentage of the total distance between the current point and the selected vertex that the next point
    /// should move. For example, if this is 0.5, the next point will be halfway between the current point and the
    /// next selected vertex.
    public let distanceFactor: CGFloat


    /// Creates and returns a new `ChaosGameSequence` with the specified initial point, vertex selector, and distance
    /// factor.
    ///
    /// - Parameters:
    ///   - initialPoint: The initial point with which to start the algorithm.
    ///   - vertexSelector: The vertex selector to use when selecting a vertex to move towards.
    ///   - distanceFactor: The percentage of the total distance between the current point and the selected vertex that
    ///     the next point should move. For example, if this is 0.5, the next point will be halfway between the current
    ///     point and the next selected vertex.
    public init(initialPoint: CGPoint, vertexSelector: PolygonVertexSelector, distanceFactor: CGFloat) {
        precondition(distanceFactor > 0 && distanceFactor < 1)
        self.initialPoint = initialPoint
        self.vertexSelector = vertexSelector
        self.distanceFactor = distanceFactor
    }


    /// The polygon from which vertices are selected.
    public var polygon: Polygon {
        return vertexSelector.polygon
    }


    public func makeIterator() -> ChaosGameSequence.Iterator {
        return Iterator(vertexSelector: vertexSelector, distanceFactor: distanceFactor, lastPoint: initialPoint)
    }


    public struct Iterator : IteratorProtocol {
        /// The instance’s vertex selector.
        private(set) var vertexSelector: PolygonVertexSelector

        /// The instance’s distance factor.
        let distanceFactor: CGFloat

        /// The last point generated by the sequence
        private(set) var lastPoint: CGPoint


        public mutating func next() -> CGPoint? {
            let selectedVertex = vertexSelector.selectVertex()
            lastPoint = CGPoint(x: (1 - distanceFactor) * lastPoint.x + distanceFactor * selectedVertex.x,
                                y: (1 - distanceFactor) * lastPoint.y + distanceFactor * selectedVertex.y)
            return lastPoint
        }
    }
}