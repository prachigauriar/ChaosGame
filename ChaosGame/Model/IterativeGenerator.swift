//
//  IterativeGenerator.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/28/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Foundation


public protocol IterativeGenerator {
    associatedtype Output
 
    var iteration: Int { get }
    func generate() -> Output
}


public class TimedIterativeGenerator<Generator : IterativeGenerator> {
    private let generationQueue: DispatchQueue
    
    public let generator: Generator
    
    public var updateInterval: TimeInterval = 1 {
        willSet {
            precondition(newValue > 0)
        }
    }
    
    public var updateBlock: ((Generator.Output) -> Void)?
    
    public private(set) var isRunning: Bool = false

    public init(generator: Generator, updateBlock: ((Generator.Output) -> Void)? = nil) {
        self.generator = generator
        self.generationQueue = DispatchQueue(label: "TimedIterativeGenerator")
        self.updateBlock = updateBlock
    }
    
    
    public func start() {
        guard !isRunning else {
            return
        }
        
        isRunning = true
        scheduleNextGeneration()
    }
    
    
    public func stop() {
        isRunning = false
    }

    
    private func scheduleNextGeneration() {
        guard isRunning else {
            return
        }

        generationQueue.asyncAfter(deadline: .now() + updateInterval, qos: .userInitiated) {
            self.generate()
        }
    }

    
    private func generate() {
        self.updateBlock?(self.generator.generate())
        scheduleNextGeneration()
    }
}
