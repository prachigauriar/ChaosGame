//
//  ChaosGamePointGenerator.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/27/2017.
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
        let x = (1 - distanceFactor) * point1.x + distanceFactor * point2.x
        let y = (1 - distanceFactor) * point1.y + distanceFactor * point2.y
        return CGPoint(x: x, y: y)
    }
}
