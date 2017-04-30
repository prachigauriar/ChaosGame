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
    
    
    // MARK: -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    public override func viewDidLayout() {
        guard pointPlotView.bounds.area != 0 else {
            return
        }
                
        reset()
    }
    

    public func startMonitoringGameRunner() {
        guard gameRunner != nil else {
            return
        }
        
        interfaceUpdateTimer?.invalidate()
        interfaceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1 / 60.0, repeats: true) { [unowned self] _ in
            self.updateInterface()
        }
    }
    
    
    public func stopMonitoringGameRunner() {
        interfaceUpdateTimer?.invalidate()
    }
    
    
    public func reset() {
        pointPlotView.removeAllPoints()
        
        guard let gameRunner = gameRunner else {
            return
        }
        
        pointPlotView.plot(gameRunner.polygon.vertices, color: .blue, radius: 5)
        plot(gameRunner.allPoints)
        pointPlotView.plot([gameRunner.initialPoint], color: .red, radius: 3)
        iterationLabel.integerValue = gameRunner.iteration
    }

    
    private func updateInterface() {
        guard let gameRunner = gameRunner else {
            return
        }
        
        plot(gameRunner.flushAccumulatedPoints())
        iterationLabel.integerValue = gameRunner.iteration
    }
    
    
    private func plot(_ points: [CGPoint]) {
        pointPlotView.plot(points, color: .white, radius: 0.5)
    }
}
