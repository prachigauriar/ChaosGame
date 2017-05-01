//
//  QueueTimer.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/30/2017.
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


public class QueueTimer {
    private let queue: DispatchQueue
    private let interval: TimeInterval
    private let repeats: Bool
    private var block: ((QueueTimer) -> Void)?
    private var isScheduled: Bool = false
    
    
    public init(label: String = "", interval: TimeInterval, repeats: Bool = true, block: @escaping (QueueTimer) -> Void) {
        self.queue = DispatchQueue(label: label)
        self.interval = interval
        self.repeats = repeats
        self.block = block
    }
    
    
    public static func scheduledTimer(label: String = "", interval: TimeInterval, repeats: Bool = true, block: @escaping (QueueTimer) -> Void) -> QueueTimer {
        let timer = QueueTimer(label: label, interval: interval, repeats: repeats, block: block)
        timer.schedule()
        return timer
    }
    
    
    public func schedule() {
        guard block != nil else {
            return
        }
        
        isScheduled = true
        scheduleNext()
    }

    
    public func invalidate() {
        isScheduled = false
        block = nil
    }
    
    
    private func scheduleNext() {
        guard isScheduled else {
            return
        }
        
        queue.asyncAfter(deadline: .now() + interval) { [weak self] in
            guard let strongSelf = self, let block = strongSelf.block else {
                return
            }
            
            block(strongSelf)
            
            if strongSelf.repeats {
                strongSelf.scheduleNext()
            } else {
                strongSelf.invalidate()
            }
        }
    }
}
