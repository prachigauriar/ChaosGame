//
//  ChaosGamePlotViewController.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Cocoa


public class ChaosGamePlotViewController : NSViewController {
    // Model
    public var gameRunner: ChaosGameRunner? {
        didSet {
            if isViewLoaded {
                reset()
            }
        }
    }

    private var pointPlotter: PointPlotter!
    
    
    // Controller State
    private lazy var iterationFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    private var interfaceUpdateTimer: Timer?

    
    // View
    @IBOutlet weak var pointPlotView: NSImageView!
    @IBOutlet weak var iterationLabel: NSTextField!
    
    
    // MARK: -
    
    override public func viewDidLayout() {
        guard pointPlotView.bounds.area != 0 else {
            return
        }
                
        pointPlotter = PointPlotter(size: pointPlotView.bounds.size, backgroundColor: .black)
        pointPlotView.image = pointPlotter.image
        reset()
    }
    

    public func startMonitoringGameRunner() {
        guard gameRunner != nil else {
            return
        }
        
        interfaceUpdateTimer?.invalidate()
        interfaceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1 / 30.0, repeats: true) { [unowned self] _ in
            self.updateInterface()
        }
    }
    
    
    public func stopMonitoringGameRunner() {
        interfaceUpdateTimer?.invalidate()
    }
    
    
    public func reset() {
        pointPlotter.removeAllPoints()
        
        guard let gameRunner = gameRunner else {
            return
        }
        
        pointPlotter.plot(gameRunner.polygon.vertices, color: .blue, radius: 5)
        pointPlotter.plot(gameRunner.initialPoint, color: .red, radius: 3)
        plot(gameRunner.allPoints)
        
        iterationLabel.integerValue = gameRunner.iteration
    }

    
    private func updateInterface() {
        guard let gameRunner = gameRunner else {
            return
        }
        
        plot(gameRunner.flushAccumulatedPoints())
        pointPlotView.setNeedsDisplay()
        iterationLabel.integerValue = gameRunner.iteration
    }
    
    
    private func plot(_ points: [CGPoint]) {
        pointPlotter.plot(points, color: .white, radius: 1)
    }
}
