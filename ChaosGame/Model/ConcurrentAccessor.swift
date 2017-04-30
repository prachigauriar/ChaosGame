//
//  ConcurrentAccessor.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
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
