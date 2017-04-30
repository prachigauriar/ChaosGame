//
//  PolygonVertexSelector.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
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
            previouslyChosenIndexes.append(index)
            
            if previouslyChosenIndexes.count > keptChoiceCount {
                previouslyChosenIndexes.remove(at: 0)
            }
        }
        
        return polygon.vertices[index]
    }
}


public extension RandomPolygonVertexSelector {
    public static func anyVertexSelector(with polygon: Polygon) -> RandomPolygonVertexSelector {
        return RandomPolygonVertexSelector(polygon: polygon, keptChoiceCount: 0) { (index, previouslyChosenIndexes) -> Bool in
            return true
        }
    }

    
    public static func nonRepeatingVertexSelector(with polygon: Polygon) -> RandomPolygonVertexSelector {
        return RandomPolygonVertexSelector(polygon: polygon, keptChoiceCount: 1) { (index, previouslyChosenIndexes) -> Bool in
            return index != previouslyChosenIndexes.last
        }
    }
}