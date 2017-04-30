//
//  ImageDataSourceView.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/30/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Cocoa


public class ImageDataSourceView : NSView {
    public var imageAccessor: ConcurrentAccessor<NSImage>?
    
    
    public override func draw(_ dirtyRect: NSRect) {
        guard let imageAccessor = imageAccessor else {
            return
        }
        
        imageAccessor.read { image in
            image.draw(in: dirtyRect, from: dirtyRect, operation: .copy, fraction: 1.0)
        }
    }
}
