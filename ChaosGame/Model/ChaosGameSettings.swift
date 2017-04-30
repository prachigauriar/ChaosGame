//
//  ChaosGameSettings.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
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
    
    
    public func makeChaosGame(boundingRect: CGRect, updateBlock: ((CGPoint) -> Void)? = nil) -> TimedIterativeGenerator<ChaosGamePointGenerator> {
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
        
        let generator = ChaosGamePointGenerator(initialPoint: CGPoint.randomPoint(in: boundingRect),
                                                vertexSelector: vertexSelector, 
                                                distanceFactor: CGFloat(distanceFactor))
        
        return TimedIterativeGenerator(generator: generator, updateBlock: updateBlock)
    }
}
