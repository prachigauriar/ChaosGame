//
//  NSImage+Drawing.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/30/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Cocoa


public extension NSImage {
    public func withLockedFocus(block: () -> Void) {
        lockFocus()
        block()
        unlockFocus()
    }
}
