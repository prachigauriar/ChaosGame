//
//  PointPlotView.swift
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
