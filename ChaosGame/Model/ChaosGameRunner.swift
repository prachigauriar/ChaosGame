//
//  ChaosGameRunner.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Foundation


public class ChaosGameRunner {
    private let chaosGame: TimedIterativeGenerator<ChaosGamePointGenerator>
    private let accumulatedPointsAccessor: ConcurrentAccessor<[CGPoint]> = ConcurrentAccessor([])
    
    
    public var polygon: Polygon {
        return chaosGame.generator.vertexSelector.polygon
    }
    
    
    public var initialPoint: CGPoint {
        return chaosGame.generator.initialPoint
    }
    
    
    public var iteration: Int {
        return chaosGame.generator.iteration
    }
    
    
    public var updateInterval: TimeInterval {
        get {
            return chaosGame.updateInterval
        }
        
        set {
            chaosGame.updateInterval = newValue
        }
    }

    
    public var allPoints: [CGPoint] {
        return chaosGame.generator.points
    }
    
    
    var isRunning: Bool {
        return chaosGame.isRunning
    }

    
    public init(settings: ChaosGameSettings, boundingRect: CGRect) {
        chaosGame = settings.makeChaosGame(boundingRect: boundingRect)
        chaosGame.updateBlock = self.add(_:)
    }
    
    
    private func add(_ point: CGPoint) {
        accumulatedPointsAccessor.asyncWrite { accumulatedPoints in
            accumulatedPoints.append(point)
        }
    }
    
    
    public func flushAccumulatedPoints() -> [CGPoint] {
        var points: [CGPoint]? = nil
        accumulatedPointsAccessor.syncWrite { (accumulatedPoints) in
            points = accumulatedPoints
            accumulatedPoints.removeAll()
        }
        
        return points!
    }
    
    
    public func start() {
        chaosGame.start()
    }
    
    
    public func stop() {
        chaosGame.stop()
    }
}


extension CGPoint {
    static func randomPoint(in rect: CGRect) -> CGPoint {
        let resolution: CGFloat = 100000
        let x = CGFloat(arc4random_uniform(UInt32(resolution))) / resolution
        let y = CGFloat(arc4random_uniform(UInt32(resolution))) / resolution
        return CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
    }
}
