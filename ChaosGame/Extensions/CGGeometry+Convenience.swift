//
//  CGGeometry+Convenience.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/30/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import CoreGraphics


public extension CGRect {
    public var area: CGFloat {
        return width * height
    }

    
    public var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}


public extension CGSize {
    public var area: CGFloat {
        return width * height
    }
}
