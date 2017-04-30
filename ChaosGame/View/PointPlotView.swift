//
//  PointPlotView.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/28/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Cocoa


class PointPlotView : NSView {
    private var drawActions: [(CGContext, CGRect) -> Void] = []
    
    private var pointTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: bounds.width, y: bounds.height)
    }
    
    
    override func draw(_ dirtyRect: CGRect) {
        guard let context = NSGraphicsContext.current() else {
            return
        }
        
        let cgContext = context.cgContext
        cgContext.setFillColor(.white)
        cgContext.fill(dirtyRect)
        
        for drawAction in drawActions {
            drawAction(cgContext, dirtyRect)
        }
    }
    
    public func addEmphasizedPoint(_ point: CGPoint, color: NSColor) {
        addPoint(point, sideLength: 5, fillColor: color) { (context, rect) in
            context.fillEllipse(in: rect)
        }
    }
    
    
    public func addPoint(_ point: CGPoint) {
        addPoint(point, sideLength: 2, fillColor: .black) { (context, rect) in
            context.fill(rect)
        }
    }

    
    public func removeAllPoints() {
        drawActions.removeAll()
        needsDisplay = true
    }
    
    
    private func addPoint(_ point: CGPoint, sideLength: CGFloat, fillColor: NSColor, drawBlock: @escaping (CGContext, CGRect) -> Void) {
        let transformedPoint = point.applying(pointTransform)
        let rect = CGRect(origin: transformedPoint, size: .zero).insetBy(dx: -sideLength / 2, dy: -sideLength / 2)

        drawActions.append { (context, drawRect) in
            if rect.intersects(drawRect) {
                context.setFillColor(fillColor.cgColor)
                drawBlock(context, rect)
            }
        }
        
        setNeedsDisplay(rect)
    }
}
