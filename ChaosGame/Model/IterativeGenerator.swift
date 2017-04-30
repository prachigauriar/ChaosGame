//
//  IterativeGenerator.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/28/2017.
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
