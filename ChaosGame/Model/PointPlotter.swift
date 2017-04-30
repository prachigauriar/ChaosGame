//
//  PointPlotter.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Cocoa


public class PointPlotter {
    public let image: NSImage
    public let backgroundColor: NSColor
    private let queue = DispatchQueue(label: "PointPlotter", qos: .userInitiated)
    
    public init(size: CGSize, backgroundColor: NSColor) {
        precondition(size.area > 0)
        
        self.image = NSImage(size: size)
        self.image.backgroundColor = backgroundColor
        self.backgroundColor = backgroundColor
    }
    
    
    public func plot(_ point: CGPoint, color: NSColor, radius: CGFloat) {
        plot([point], color: color, radius: radius)
    }
    
    
    public func plot(_ points: [CGPoint], color: NSColor, radius: CGFloat) {
        queue.async {
            self.image.withLockedFocus {
                for point in points {
                    let pointRect = self.rect(for: point, radius: radius)
                    let bezierPath = radius > 2 ? NSBezierPath(ovalIn: pointRect) : NSBezierPath(rect: pointRect)
                    
                    color.setFill()
                    bezierPath.fill()
                }
                
                NSGraphicsContext.current()?.flushGraphics()
            }
        }
    }
    
    
    public func removeAllPoints() {
        drawBackground()
    }

    
    // MARK: - Drawing Methods
    
    private var pointTransform: AffineTransform {
        return AffineTransform(scaleByX: image.size.width, byY: image.size.height)
    }
    
    
    private func drawBackground() {
        queue.async {
            self.image.withLockedFocus {
                self.backgroundColor.setFill()
                NSBezierPath(rect: CGRect(origin: .zero, size: self.image.size)).fill()
                NSGraphicsContext.current()?.flushGraphics()
            }
        }
    }
    
    
    private func rect(for point: CGPoint, radius: CGFloat) -> CGRect {
        let transformedPoint = pointTransform.transform(point)
        return CGRect(origin: transformedPoint, size: .zero).insetBy(dx: -radius, dy: -radius)
    }
}
