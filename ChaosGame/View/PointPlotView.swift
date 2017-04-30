//
//  PointPlotView.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/30/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Cocoa


public class PointPlotView : NSView {
    public var backgroundColor: NSColor = .black {
        didSet {
            needsDisplay = true
        }
    }
    
    
    private var backingImageAccessor: ConcurrentAccessor<NSImage>! {
        didSet {
            needsDisplay = true
        }
    }
    
    
    public override var bounds: NSRect {
        didSet {
            if bounds.area > 0 && oldValue.size != bounds.size {
                backingImageAccessor = ConcurrentAccessor(NSImage(size: bounds.size))
            }
        }
    }

    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        canDrawConcurrently = true
    }
    
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        canDrawConcurrently = true
    }
    
    
    // MARK: - Drawing
    
    public override func draw(_ dirtyRect: NSRect) {
        backgroundColor.setFill()
        NSRectFill(dirtyRect)
        
        backingImageAccessor.read { image in
            image.draw(in: dirtyRect, from: dirtyRect, operation: .sourceOver, fraction: 1.0)
        }
    }
    
    
    public func plot(_ points: [CGPoint], color: NSColor, radius: CGFloat) {
        guard !points.isEmpty else {
            return
        }
        
        backingImageAccessor.asyncWrite { image in
            var dirtyRects: [CGRect] = []
            image.withLockedFocus {
                for point in points {
                    let pointRect = self.rect(for: point, radius: radius)
                    let bezierPath = radius > 2 ? NSBezierPath(ovalIn: pointRect) : NSBezierPath(rect: pointRect)
                    
                    color.setFill()
                    bezierPath.fill()
                    
                    dirtyRects.append(pointRect)
                }
                
                NSGraphicsContext.current()?.flushGraphics()
            }

            DispatchQueue.main.async {
                for rect in dirtyRects {
                    self.setNeedsDisplay(rect)
                }
            }
        }
    }
    
    
    public func removeAllPoints() {
        backingImageAccessor = ConcurrentAccessor(NSImage(size: bounds.size))
    }
    
    
    private var pointTransform: AffineTransform {
        return AffineTransform(scaleByX: bounds.width, byY: bounds.height)
    }
    
    
    private func rect(for point: CGPoint, radius: CGFloat) -> CGRect {
        let transformedPoint = pointTransform.transform(point)
        return CGRect(origin: transformedPoint, size: .zero).insetBy(dx: -radius, dy: -radius)
    }
}
