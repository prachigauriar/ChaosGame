//
//  PointPlotter.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Cocoa


public class PointPlotter {
    private let size: CGSize
    public let imageAccessor: ConcurrentAccessor<NSImage>
    public let backgroundColor: NSColor
    private let completionQueue = DispatchQueue(label: "PointPlotter", qos: .userInitiated)

    
    public init(size: CGSize, backgroundColor: NSColor) {
        precondition(size.area > 0)
        
        self.size = size
        let image = NSImage(size: size)
        image.backgroundColor = backgroundColor
        self.imageAccessor = ConcurrentAccessor(image)
        self.backgroundColor = backgroundColor
    }
    
    
    public func plot(_ points: [CGPoint], color: NSColor, radius: CGFloat, completion: (([CGRect]) -> Void)? = nil) {
        guard points.count > 0 else {
            completion?([])
            return
        }
        
        var dirtyRects: [CGRect] = []
        
        imageAccessor.asyncWrite { image in
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
            
            if let completion = completion {
                self.completionQueue.async {
                    completion(dirtyRects)
                }
            }
        }
    }
    
    
    public func removeAllPoints(completion: (() -> Void)? = nil) {
        drawBackground(completion: completion)
    }

    
    // MARK: - Drawing Methods
    
    private var pointTransform: AffineTransform {
        return AffineTransform(scaleByX: size.width, byY: size.height)
    }
    
    
    private func drawBackground(completion: (() -> Void)?) {
        imageAccessor.asyncWrite { image in
            image.withLockedFocus {
                self.backgroundColor.setFill()
                NSBezierPath(rect: CGRect(origin: .zero, size: self.size)).fill()
                NSGraphicsContext.current()?.flushGraphics()
            }
            
            if let completion = completion {
                self.completionQueue.async {
                    completion()
                }
            }
        }
    }
    
    
    private func rect(for point: CGPoint, radius: CGFloat) -> CGRect {
        let transformedPoint = pointTransform.transform(point)
        return CGRect(origin: transformedPoint, size: .zero).insetBy(dx: -radius, dy: -radius)
    }
}
