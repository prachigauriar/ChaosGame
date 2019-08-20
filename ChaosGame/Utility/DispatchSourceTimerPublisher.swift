//
//  DispatchSourceTimerPublisher.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 6/28/2019.
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

import Dispatch
import Foundation
import Combine


/// `DispatchSourceTimerPublisher`s model `DispatchSourceTimer`s as publishers.
public struct DispatchSourceTimerPublisher : Publisher {
    public typealias Output = Date
    public typealias Failure = Never

    /// The interval between firings of the timer.
    private let interval: TimeInterval

    /// The queue on which the timer fires. If `nil`, a default is chosen.
    private let queue: DispatchQueue?

    /// Whether the instance respects demand changes after the initial demand is requested. This largely exists so that
    /// we can investigate potential bugs in the Combine framework.
    private let respectsDemandChanges: Bool


    /// Creates a new `DispatchSourceTimerPublisher` with the specified interval and queue.
    ///
    /// - Parameters:
    ///   - interval: The interval between firings of the timer.
    ///   - queue: The queue on which the timer should fire.
    ///   - respectsDemandChanges: Whether the instance respects demand changes after the initial demand is requested.
    public init(interval: TimeInterval, queue: DispatchQueue? = nil, respectsDemandChanges: Bool = false) {
        self.interval = interval
        self.queue = queue
        self.respectsDemandChanges = respectsDemandChanges
    }


    public func receive<S>(subscriber: S)
        where S : Subscriber, S.Failure == Never, S.Input == Date {
            let subscription = Subscription(interval: interval,
                                            queue: queue,
                                            subscriber: subscriber,
                                            respectsDemandChanges: respectsDemandChanges)
            subscriber.receive(subscription: subscription)
    }


    /// The `Subscription` class actually handles the specifics of publishing timer firings to subscribers on behalf of
    /// a `DispatchSourceTimerPublisher`.
    private class Subscription<S> : Combine.Subscription where S : Subscriber, S.Input == Date, S.Failure == Never {
        /// The interval at which the timer repeats.
        private let interval: TimeInterval

        /// The queue on which the timer fires. If `nil`, a default is chosen.
        private let queue: DispatchQueue?

        /// The subscriber of the subscription.
        private let subscriber: S

        /// The instance’s timer.
        private let timer: DispatchSourceTimer

        /// The demand requested by the subscriber.
        private var demand: Subscribers.Demand = .unlimited

        /// Whether the instance is finished yet.
        private var isFinished = false


        /// Creates a new subscription with the specified interval, queue, and subscriber.
        ///
        /// - Parameters:
        ///   - interval: The interval between firings of the timer.
        ///   - queue: The queue on which the timer should fire.
        ///   - subscriber: The subscriber of the subscription.
        ///   - respectsDemandChanges: Whether the instance respects demand changes after the initial demand is requested.
        init(interval: TimeInterval, queue: DispatchQueue?, subscriber: S, respectsDemandChanges: Bool) {
            self.interval = interval
            self.queue = queue
            self.subscriber = subscriber

            timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)

            timer.setEventHandler { [weak self] in
                guard let self = self else {
                    return
                }

                // Send the current date to the subscriber
                let subscriberDemand = self.subscriber.receive(Date())

                // If we respect demand changes, our demand will be whatever the subscriber returned. Otherwise, we
                // just decrement our demand by 1.
                if respectsDemandChanges {
                    self.demand = subscriberDemand
                } else if self.demand != .none {
                    self.demand -= 1
                }

                // If there’s no demand left, cancel and mark ourselves as finished.
                if self.demand == .none {
                    self.cancel()

                    if !self.isFinished {
                        self.isFinished = true
                        subscriber.receive(completion: .finished)
                    }
                }
            }
        }


        func request(_ demand: Subscribers.Demand) {
            timer.schedule(deadline: .now(), repeating: interval)
            self.demand = demand

            if demand != .none {
                timer.activate()
            }
        }


        func cancel() {
            if !timer.isCancelled {
                timer.cancel()
            }
        }
    }
}


public extension DispatchSource {
    /// Creates a new `DispatchSourceTimerPublisher` with the specified interval and queue.
    ///
    /// - Parameters:
    ///   - interval: The interval between firings of the timer.
    ///   - queue: The queue on which the timer should fire.
    ///   - respectsDemandChanges: Whether the instance respects demand changes after the initial demand is requested.
    static func timerPublisher(interval: TimeInterval,
                               queue: DispatchQueue? = nil,
                               respectsDemandChanges: Bool = false) -> DispatchSourceTimerPublisher {
        return DispatchSourceTimerPublisher(interval: interval, queue: queue, respectsDemandChanges: respectsDemandChanges)
    }
}
