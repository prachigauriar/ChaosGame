//
//  ChaosGamePointGenerator.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/27/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import CoreGraphics
import Foundation


public class ChaosGamePointGenerator : IterativeGenerator {
    public private(set) var vertexSelector: PolygonVertexSelector
    public private(set) var points: [CGPoint]
    public let distanceFactor: CGFloat
    
    public var iteration: Int {
        return points.count - 1
    }
    
    public var initialPoint: CGPoint {
        return points[0]
    }
    
    private var lastPoint: CGPoint {
        return points[iteration]
    }
    
    
    public init(initialPoint: CGPoint, vertexSelector: PolygonVertexSelector, distanceFactor: CGFloat) {
        precondition(distanceFactor > 0 && distanceFactor < 1)
        
        self.vertexSelector = vertexSelector
        points = [initialPoint]
        self.distanceFactor = distanceFactor
    }
    

    public func generate() -> CGPoint {
        let point = pointBetween(lastPoint, and: vertexSelector.selectVertex(), distanceFactor: distanceFactor)
        points.append(point)
        return point
    }
    
    
    private func pointBetween(_ point1: CGPoint, and point2: CGPoint, distanceFactor: CGFloat) -> CGPoint {
        let x = distanceFactor * point1.x + (1 - distanceFactor) * point2.x
        let y = distanceFactor * point1.y + (1 - distanceFactor) * point2.y        
        return CGPoint(x: x, y: y)
    }
}
