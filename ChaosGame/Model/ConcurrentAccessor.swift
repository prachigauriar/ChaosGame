//
//  ConcurrentAccessor.swift
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


public class ConcurrentAccessor<BaseType> : CustomStringConvertible {
    private var base: BaseType
    private let queue: DispatchQueue
    

    public init(_ base: BaseType) {
        self.base = base
        self.queue = DispatchQueue(label: "\(type(of: self))", attributes: .concurrent)
    }
    
    
    public var description: String {
        let baseDescription = read { "\($0)" }
        return "<\(type(of: self)): queue=\(queue) base=\(baseDescription)>"
    }
    

    public func read<ReturnType>(_ body: (BaseType) -> ReturnType) -> ReturnType {
        var returnValue: ReturnType? = nil
        queue.sync {
            returnValue = body(base)
        }
        
        return returnValue!
    }
    
    
    public func asyncWrite(_ body: @escaping (inout BaseType) -> ()) {
        queue.async(flags: .barrier) {
            body(&self.base)
        }
    }

    
    public func syncWrite(_ body: (inout BaseType) -> ()) {
        queue.sync(flags: .barrier) {
            body(&self.base)
        }
    }
}
