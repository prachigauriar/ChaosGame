//
//  Polygon.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Foundation


public struct Polygon {
    public var vertices: [CGPoint]
    
    public init(vertices: [CGPoint]) {
        precondition(vertices.count > 2)
        self.vertices = vertices
    }
}


public extension Polygon {
    public static func regularPolygon(withVertexCount vertexCount: Int, inside rect: CGRect) -> Polygon {
        let r = min(rect.width, rect.height) / 2
        let baseTheta = 2 * .pi / CGFloat(vertexCount)
        
        let center = rect.center
        let vertices = (0 ..< vertexCount).map { i -> CGPoint in
            let theta = CGFloat(i) * baseTheta
            return CGPoint(x: r * cos(theta) + center.x, y: r * sin(theta) + center.y)
        }
        
        return Polygon(vertices: vertices)
    }
}


public extension CGRect {
    public var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    
    public func contains(_ polygon: Polygon) -> Bool {
        return polygon.vertices.first { !contains($0) } == nil
    }
}
