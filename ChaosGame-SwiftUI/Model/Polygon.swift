//
//  Polygon.swift
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


struct Polygon {
    var vertices: [CGPoint]
    
    
    init(vertices: [CGPoint]) {
        precondition(vertices.count > 2)
        self.vertices = vertices
    }
    
    
    var boundingRect: CGRect {
        let initialUnionRect = CGRect(origin: vertices[0], size: .zero)

        return self.vertices.reduce(initialUnionRect) { (unionRect, vertex) in
            return unionRect.union(CGRect(origin: vertex, size: .zero))
        }
    }
}


extension Polygon {
    static func regularPolygon(withVertexCount vertexCount: Int, inside rect: CGRect) -> Polygon {
        let r = min(rect.width, rect.height) / 2
        let baseTheta = 2 * .pi / CGFloat(vertexCount)
        let offset = vertexCount % 2 == 0 ? baseTheta / 2 : .pi / 2
        
        let center = rect.center
        let vertices = (0 ..< vertexCount).map { i -> CGPoint in
            let theta = CGFloat(i) * baseTheta + offset
            return CGPoint(x: r * cos(theta) + center.x, y: r * sin(theta) + center.y)
        }
        
        return Polygon(vertices: vertices)
    }
}


extension CGRect {    
    func contains(_ polygon: Polygon) -> Bool {
        return polygon.vertices.first { !contains($0) } == nil
    }
}
