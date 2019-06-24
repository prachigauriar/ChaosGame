//
//  TimedIterativeGenerator.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 6/25/2019.
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

import Combine
import Foundation


final class TimedIterativeGenerator<Generator> where Generator : IterativeGenerator {
    private(set) var generator: Generator

    private let didGenerate = PassthroughSubject<GeneratedBatch<Generator.Value>, Never>()

    lazy var batchPublisher: AnyPublisher<GeneratedBatch<Generator.Value>, Never> = {
        return didGenerate.eraseToAnyPublisher()
    }()


    private var timer: DispatchSourceTimer?

    private lazy var queue: DispatchQueue = {
        return DispatchQueue(label: "TimedIterativeGenerator.\(ObjectIdentifier(self))")
    }()


    init(generator: Generator) {
        self.generator = generator
    }


    deinit {
        timer?.cancel()
    }


    // Values/sec to generate
    var frequency: Int = 1 {
        didSet {
            precondition(frequency >= 1, "frequency must be positive")

            guard frequency != oldValue else {
                return
            }

            if isRunning {
                stop()
                start()
            }
        }
    }


    var isRunning: Bool {
        get {
            return timer?.isCancelled == false
        }

        set {
            guard isRunning != newValue else {
                return
            }

            if newValue {
                start()
            } else {
                stop()
            }
        }
    }


    private func start() {
        guard !isRunning else {
            return
        }

        let updateFrequency = min(frequency, 60)

        var generationIteration = 0
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        timer?.schedule(deadline: .now(), repeating: 1 / Double(updateFrequency))
        timer?.setEventHandler { [weak self] in
            guard let self = self else {
                return
            }

            var batchSize = self.frequency / updateFrequency
            if generationIteration == 0 {
                batchSize += self.frequency % updateFrequency
            }

            self.didGenerate.send(self.generator.generateBatch(size: batchSize))

            generationIteration = (generationIteration + 1) % updateFrequency
        }

        timer?.activate()
    }


    private func stop() {
        timer?.cancel()
    }
}
