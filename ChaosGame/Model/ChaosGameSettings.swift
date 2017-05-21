//
//  ChaosGameSettings.swift
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

import Cocoa


public enum VertexSelectionStrategy : Int {
    case random
    case nonRepeating
    case notOneCounterClockwisePlaceAway
}


public struct ChaosGameSettings {
    public var polygonVertexCount: Int = 3 {
        willSet {
            precondition(newValue > 2)
        }
    }
    
    public var distanceFactor: Double = 0.5 {
        willSet {
            precondition(newValue > 0 && newValue < 1)
        }
    }
    
    public var vertexSelectionStrategy: VertexSelectionStrategy = .random
    
    
    public init() {
    }
    
    
    public init(polygonVertexCount: Int, distanceFactor: Double, vertexSelectionStrategy: VertexSelectionStrategy) {
        precondition(polygonVertexCount > 2)
        precondition(distanceFactor > 0 && distanceFactor < 1)
        
        self.polygonVertexCount = polygonVertexCount
        self.distanceFactor = distanceFactor
        self.vertexSelectionStrategy = vertexSelectionStrategy
    }
    
    
    public func makeChaosGame(boundingRect: CGRect) -> ChaosGamePointGenerator {
        let polygon = Polygon.regularPolygon(withVertexCount: polygonVertexCount, inside: boundingRect)
        
        let vertexSelector: PolygonVertexSelector
        switch vertexSelectionStrategy {
        case .random:
            vertexSelector = RandomPolygonVertexSelector.anyVertexSelector(with: polygon)
        case .nonRepeating:
            vertexSelector = RandomPolygonVertexSelector.nonRepeatingVertexSelector(with: polygon)
        case .notOneCounterClockwisePlaceAway:
            vertexSelector = RandomPolygonVertexSelector.notOneCounterClockwisePlaceAwayVertexSelector(with: polygon)
        }
        
        return ChaosGamePointGenerator(initialPoint: CGPoint.randomPoint(in: polygon.boundingRect),
                                       vertexSelector: vertexSelector,
                                       distanceFactor: CGFloat(distanceFactor))
    }
}
