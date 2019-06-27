//
//  PolygonVertexSelector.swift
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


/// `PolygonVertexSelector`s select a vertex from a polygon.
public protocol PolygonVertexSelector {
    /// The polygon.
    var polygon: Polygon { get }

    /// Selects and returns one of the polygon’s vertices.
    mutating func selectVertex() -> CGPoint
}


/// `RandomPolygonVertexSelector`s randomly select a vertex from a polygon that meets certain criteria.
public struct RandomPolygonVertexSelector : PolygonVertexSelector {
    /// The polygon from which to select vertices.
    public let polygon: Polygon

    /// The number of previously chosen vertices to retain. These choices are passed into the `selectionPredicate` so
    /// that it can consider them when choosing which vertices are acceptable.
    public let keptSelectionCount: Int

    /// A closure that returns whether a given randomly selected vertex can be selected.
    public let selectionPredicate: (Int, [Int]) -> Bool

    /// An array of previously selected indexes. This array will have at most `keptSelectionCount` elements.
    private var previousSelectedIndexes: [Int] = []
    

    /// Creates a new `RandomPolygonVertexSelector`.
    ///
    /// - Parameters:
    ///   - polygon: The polygon from which to select vertices.
    ///   - keptSelectionCount: The number of previously chosen vertices to retain.
    ///   - selectionPredicate: A closure that returns whether a given randomly selected vertex can be selected. It
    ///     takes two parameters, the index of the randomly selected vertex, and the `keptSelectionCount` most recently
    ///     chosen indexes.
    public init(polygon: Polygon, keptSelectionCount: Int, selectionPredicate: @escaping (Int, [Int]) -> Bool) {
        self.polygon = polygon
        self.keptSelectionCount = keptSelectionCount
        self.selectionPredicate = selectionPredicate
    }
    
    
    public mutating func selectVertex() -> CGPoint {
        var index = Int.random(in: 0 ..< polygon.vertices.count)
        while !selectionPredicate(index, previousSelectedIndexes) {
            index = Int.random(in: 0 ..< polygon.vertices.count)
        }
        
        if keptSelectionCount > 0 {
            previousSelectedIndexes.insert(index, at: 0)
            
            if previousSelectedIndexes.count > keptSelectionCount {
                previousSelectedIndexes.remove(at: previousSelectedIndexes.count - 1)
            }
        }
        
        return polygon.vertices[index]
    }
}


public extension RandomPolygonVertexSelector {
    /// Returns a polygon vertex selector that randomly selects a vertex.
    ///
    /// - Parameter polygon: The polygon from which to select vertices.
    static func anyVertexSelector(with polygon: Polygon) -> RandomPolygonVertexSelector {
        return RandomPolygonVertexSelector(polygon: polygon, keptSelectionCount: 0) { (index, previousSelectedIndexes) -> Bool in
            return true
        }
    }


    /// Returns a polygon vertex selector that randomly selects a vertex but does not repeat the same selection twice in
    /// a row.
    ///
    /// - Parameter polygon: The polygon from which to select vertices.
    static func nonRepeatingVertexSelector(with polygon: Polygon) -> RandomPolygonVertexSelector {
        return RandomPolygonVertexSelector(polygon: polygon, keptSelectionCount: 1) { (index, previousSelectedIndexes) -> Bool in
            guard !previousSelectedIndexes.isEmpty else {
                return true
            }
            
            return index != previousSelectedIndexes[0]
        }
    }
    
    
    /// Returns a polygon vertex selector that randomly selects a vertex within `places` positions from the previous
    /// selection.
    ///
    /// - Parameters
    ///   - polygon: The polygon from which to select vertices.
    ///   - places: The number of (counter-clockwise) places away from the previous selection that the next selection
    ///     must be. For example, if this value is 3, the next selection must be 4 or more vertices away from the
    ///     previous selection counting counter-clockwise.
    static func notNPlacesAwayVertexSelector(with polygon: Polygon, places: Int) -> RandomPolygonVertexSelector {
        return RandomPolygonVertexSelector(polygon: polygon, keptSelectionCount: 1) { (index, previousSelectedIndexes) -> Bool in
            guard !previousSelectedIndexes.isEmpty else {
                return true
            }

            let vertexCount = polygon.vertices.count
            let lastIndex = previousSelectedIndexes[0] % vertexCount
            
            return lastIndex != ((index + places) % vertexCount)
        }
    }


    /// Returns a polygon vertex selector that randomly selects a vertex but does not allow a vertex that is adjacent to
    /// the previous selection if the previous selection was selected twice in a row.
    ///
    /// - Parameter polygon: The polygon from which to select vertices.
    static func notAdjacentToPreviousIfTwoPreviousWereIdentical(with polygon: Polygon) -> RandomPolygonVertexSelector {
        return RandomPolygonVertexSelector(polygon: polygon, keptSelectionCount: 2) { (index, previousSelectedIndexes) -> Bool in
            guard previousSelectedIndexes.count >= 2, previousSelectedIndexes[0] == previousSelectedIndexes[1] else {
                return true
            }

            let vertexCount = polygon.vertices.count
            let lastIndex = previousSelectedIndexes[0] % vertexCount

            // Make sure that index is not ±1 from lastIndex. Switch the order of index and last index in the
            // expressions to make sure we always add before getting the remainder to avoid negative values.
            return index != ((lastIndex + 1) % vertexCount)
                && lastIndex != ((index + 1) % vertexCount)
        }
    }
}
