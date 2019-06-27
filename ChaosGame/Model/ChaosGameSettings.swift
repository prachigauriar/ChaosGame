//
//  ChaosGameSettings.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
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


/// `ChaosGameSettings` store settings that can be used to create a `ChaosGameSequence` using a regular polygon. It is
/// designed to be used as a mutable value that the user can manipulate via a user interface.
public struct ChaosGameSettings {
    /// `VertexSelectionStrategy` enumerates different vertex selection strategies for use in the Chaos Game.
    public enum VertexSelectionStrategy : CaseIterable {
        /// Indicates that selection should be random.
        case random

        /// Indicates that selection should be random, but no selection may be repeated twice in a row.
        case nonRepeating

        /// Indicates that selection should be random, but no selection may be one counter-clockwise position from the
        /// previously selected vertex.
        case notOneCounterClockwisePlaceAway

        /// Indicates that selection should be random, but no selection may be two counter-clockwise positions from the
        /// previously selected vertex.
        case notTwoCounterClockwisePlacesAway

        /// Indicates that selection should be random, but if the two previous selections were identical, the current one
        /// may not be adjacent to them.
        case notAdjacentToPreviousIfTwoPreviousWereIdentical
    }


    /// The number of vertices the polygon should have. Must be 3 or greater.
    public var polygonVertexCount: Int {
        willSet {
            precondition(newValue > 2)
        }
    }
    

    /// The distance factor for the sequence. Must be strictly greater than 0 and strictly less than 1.
    public var distanceFactor: Double {
        willSet {
            precondition(newValue > 0 && newValue < 1)
        }
    }
    

    /// The polygon vertex selection strategy that should be used.
    public var vertexSelectionStrategy: VertexSelectionStrategy


    /// Creates a new `ChaosGameSettings` instance with the specified initial values.
    ///
    /// - Parameters:
    ///   - polygonVertexCount: The number of vertices the polygon should have. Must be 3 or greater. 3 by default.
    ///   - distanceFactor: The sequence’s distance factor. Must be strictly greater than 0 and strictly less than 1.
    ///     0.5 by default.
    ///   - vertexSelectionStrategy: The polygon vertex selection strategy that should be used. `.random` by default.
    public init(polygonVertexCount: Int = 3,
                distanceFactor: Double = 0.5,
                vertexSelectionStrategy: VertexSelectionStrategy = .random) {
        precondition(polygonVertexCount > 2)
        precondition(distanceFactor > 0 && distanceFactor < 1)
        
        self.polygonVertexCount = polygonVertexCount
        self.distanceFactor = distanceFactor
        self.vertexSelectionStrategy = vertexSelectionStrategy
    }
}


public extension ChaosGameSequence {
    /// Creates a new `ChaosGameSequence` using the specified settings.
    ///
    /// - Parameter settings: The settings to use when creating the sequence.
    init(settings: ChaosGameSettings = ChaosGameSettings()) {
        let boundingRect = CGRect(x: 0, y: 0, width: 1, height: 1).insetBy(dx: 0.1, dy: 0.1)
        let polygon = Polygon.regularPolygon(withVertexCount: settings.polygonVertexCount, inside: boundingRect)

        let vertexSelector: PolygonVertexSelector
        switch settings.vertexSelectionStrategy {
        case .random:
            vertexSelector = RandomPolygonVertexSelector.anyVertexSelector(with: polygon)
        case .nonRepeating:
            vertexSelector = RandomPolygonVertexSelector.nonRepeatingVertexSelector(with: polygon)
        case .notOneCounterClockwisePlaceAway:
            vertexSelector = RandomPolygonVertexSelector.notNPlacesAwayVertexSelector(with: polygon, places: 1)
        case .notTwoCounterClockwisePlacesAway:
            vertexSelector = RandomPolygonVertexSelector.notNPlacesAwayVertexSelector(with: polygon, places: 2)
        case .notAdjacentToPreviousIfTwoPreviousWereIdentical:
            vertexSelector = RandomPolygonVertexSelector.notAdjacentToPreviousIfTwoPreviousWereIdentical(with: polygon)
        }

        self.init(initialPoint: CGPoint.random(in: polygon.boundingRect),
                  vertexSelector: vertexSelector,
                  distanceFactor: CGFloat(settings.distanceFactor))
    }
}
