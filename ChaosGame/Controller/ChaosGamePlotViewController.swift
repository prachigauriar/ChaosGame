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

    
    // Controller State
    private lazy var iterationFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    private var interfaceUpdateTimer: Timer?

    
    // View
    @IBOutlet weak var pointPlotView: PointPlotView!
    @IBOutlet weak var iterationLabel: NSTextField!
    
    
    // MARK: - Lifecycle
    
    override public func viewDidLayout() {
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
    
    
    private func updateInterface() {
        guard let gameRunner = gameRunner else {
            return
        }
        
        let accumulatedPoints = gameRunner.flushAccumulatedPoints()
        for point in accumulatedPoints {
            pointPlotView.addPoint(point)
        }
        iterationLabel.integerValue = gameRunner.iteration
    }
    
    
    public func reset() {
        pointPlotView.removeAllPoints()
        
        guard let gameRunner = gameRunner else {
            return
        }
        
        for point in gameRunner.polygon.vertices {
            pointPlotView.addEmphasizedPoint(point, color: .blue)
        }
        
        pointPlotView.addEmphasizedPoint(gameRunner.initialPoint, color: .red)
        
        for point in gameRunner.allPoints {
            pointPlotView.addPoint(point)
        }
        
        iterationLabel.integerValue = gameRunner.iteration
    }
}
