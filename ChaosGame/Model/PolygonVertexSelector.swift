//
//  PolygonVertexSelector.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar.
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


public protocol PolygonVertexSelector {
    var polygon: Polygon { get }
    mutating func selectVertex() -> CGPoint
}


public struct RandomPolygonVertexSelector : PolygonVertexSelector {
    public let polygon: Polygon
    public private(set) var previouslyChosenIndexes: [Int] = []
    public let keptChoiceCount: Int
    public let selectionPredicate: (Int, [Int]) -> Bool
    
    
    public init(polygon: Polygon, keptChoiceCount: Int, selectionPredicate: @escaping (Int, [Int]) -> Bool) {
        self.polygon = polygon
        self.keptChoiceCount = keptChoiceCount
        self.selectionPredicate = selectionPredicate
    }
    
    
    public mutating func selectVertex() -> CGPoint {
        var index = Int(arc4random_uniform(UInt32(polygon.vertices.count)))
        while !selectionPredicate(index, previouslyChosenIndexes) {
            index = Int(arc4random_uniform(UInt32(polygon.vertices.count)))
        }
        
        if keptChoiceCount > 0 {
            previouslyChosenIndexes.insert(index, at: 0)
            
            if previouslyChosenIndexes.count > keptChoiceCount {
                previouslyChosenIndexes.remove(at: previouslyChosenIndexes.count - 1)
            }
        }
        
        return polygon.vertices[index]
    }
}


public extension RandomPolygonVertexSelector {
    static func anyVertexSelector(with polygon: Polygon) -> RandomPolygonVertexSelector {
        return RandomPolygonVertexSelector(polygon: polygon, keptChoiceCount: 0) { (index, previouslyChosenIndexes) -> Bool in
            return true
        }
    }

    
    static func nonRepeatingVertexSelector(with polygon: Polygon) -> RandomPolygonVertexSelector {
        return RandomPolygonVertexSelector(polygon: polygon, keptChoiceCount: 1) { (index, previouslyChosenIndexes) -> Bool in
            guard !previouslyChosenIndexes.isEmpty else {
                return true
            }
            
            return index != previouslyChosenIndexes[0]
        }
    }
    
    
    static func notOneCounterClockwisePlaceAwayVertexSelector(with polygon: Polygon) -> RandomPolygonVertexSelector {
        return RandomPolygonVertexSelector(polygon: polygon, keptChoiceCount: 1) { (index, previouslyChosenIndexes) -> Bool in
            guard !previouslyChosenIndexes.isEmpty else {
                return true
            }

            let lastIndex = previouslyChosenIndexes[0]
            let vertexCount = polygon.vertices.count
            
            return (lastIndex % vertexCount) != ((index + 1) % vertexCount)
        }
    }
}
