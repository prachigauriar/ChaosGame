//
//  ChaosGameRunner.swift
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


public class ChaosGameRunner {
    private let pointGenerator: ChaosGamePointGenerator
    private let accumulatedPointsAccessor: ConcurrentAccessor<[CGPoint]> = ConcurrentAccessor([])
    
    private lazy var generationQueue: DispatchQueue = {
        return DispatchQueue(label: "ChaosGameRunner.generator")
    }()
    
    
    private var updateTimer: QueueTimer?
    
    
    public var polygon: Polygon {
        return pointGenerator.vertexSelector.polygon
    }
    
    
    public var initialPoint: CGPoint {
        return pointGenerator.initialPoint
    }
    
    
    public var iteration: Int {
        return pointGenerator.iteration
    }
    
    
    public var allPoints: [CGPoint] {
        return pointGenerator.points
    }

    
    public var isRunning: Bool {
        return updateTimer?.isScheduled == true
    }
    

    // Points/sec to generate
    public var generationFrequency: Int = 1 {
        didSet {
            if generationFrequency != oldValue && isRunning {
                stop()
                start()
            }
        }
    }
    
    
    private var generationIteration: Int = 0
    
    
    public init(settings: ChaosGameSettings, boundingRect: CGRect) {
        pointGenerator = settings.makeChaosGame(boundingRect: boundingRect)
    }
    
    
    deinit {
        updateTimer?.invalidate()
    }
    
    
    private func accumulatePoints(_ points: [CGPoint]) {
        accumulatedPointsAccessor.syncWrite { accumulatedPoints in
            accumulatedPoints.append(contentsOf: points)
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
        guard !isRunning else {
            return
        }
        
        let updateFrequency = min(generationFrequency, 60)
        updateTimer = QueueTimer.scheduledTimer(interval: 1 / Double(updateFrequency)) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            
            var batchSize = strongSelf.generationFrequency / updateFrequency
            if strongSelf.generationIteration == 0 {
                batchSize += strongSelf.generationFrequency % updateFrequency
            }
            
            let points = strongSelf.pointGenerator.generateBatch(size: batchSize)
            self?.accumulatePoints(points)
            strongSelf.generationIteration = (strongSelf.generationIteration + 1) % updateFrequency
        }
    }
    
    
    public func stop() {
        updateTimer?.invalidate()
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
