//
//  ChaosGameViewController.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/27/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Cocoa


public class ChaosGameViewController : NSViewController, ChaosGameSettingsViewControllerDelegate {
    // Model
    private var gameRunner: ChaosGameRunner?
    
    // Controller State
    private var settingsViewController: ChaosGameSettingsViewController!
    private var plotViewController: ChaosGamePlotViewController!
    
    // Views
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var toggleGenerationButton: NSButton!
    
    
    // MARK: - Lifecycle
    
    override public func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "ChaosGameSettingsViewControllerEmbedSegue":
            settingsViewController = segue.destinationController as! ChaosGameSettingsViewController
            settingsViewController.delegate = self
        case "ChaosGamePlotViewControllerEmbedSegue":
            plotViewController = segue.destinationController as! ChaosGamePlotViewController
        default:
            break
        }
    }
    
    
    override public func viewDidDisappear() {
        super.viewDidDisappear()
        
        if gameRunner?.isRunning == true {
            toggleGeneration(nil)
        }
    }

    
    private func initializeGameRunner() {
        updateGameRunner(with: settingsViewController.settings, frequency: settingsViewController.frequency)
    }
    
    
    private func updateGameRunner(with settings: ChaosGameSettings?, frequency: Double) {
        if let settings = settings {
            gameRunner = ChaosGameRunner(settings: settings, boundingRect: .chaosGameBoundingRect)
            plotViewController.gameRunner = gameRunner
        }
        
        if let gameRunner = gameRunner {
            gameRunner.updateInterval = 1 / frequency
        }
    }
    
    
    // MARK: - Chaos Game Settings View Controller Delegate
    
    public func chaosGameSettingsViewController(_ viewController: ChaosGameSettingsViewController, frequencyDidChange frequency: Double) {
        updateGameRunner(with: nil, frequency: frequency)
    }
    
    
    public func chaosGameSettingsViewController(_ viewController: ChaosGameSettingsViewController, settingsDidChange settings: ChaosGameSettings) {
        updateGameRunner(with: settings, frequency: viewController.frequency)
    }

    
    // MARK: - Actions
    
    @IBAction func toggleGeneration(_ sender: NSButton?) {
        if gameRunner == nil {
            initializeGameRunner()
        }
        
        let shouldStart = gameRunner!.isRunning == false
        
        if shouldStart {
            start()
        } else {
            stop()
        }
    }
    
    
    @IBAction func reset(_ sender: NSButton?) {
        stop()
        plotViewController.reset()
    }
    
    
    private func start() {
        guard let gameRunner = gameRunner else {
            return
        }

        gameRunner.start()
        plotViewController.startMonitoringGameRunner()
        toggleGenerationButton.title = NSLocalizedString("Stop", comment: "title of button that stops the Chaos Game")
        settingsViewController.areControlsAffectingSettingsEnabled = false
    }

    
    private func stop() {
        guard let gameRunner = gameRunner else {
            return
        }

        gameRunner.stop()
        plotViewController.stopMonitoringGameRunner()
        toggleGenerationButton.title = NSLocalizedString("Start", comment: "title of button that starts the Chaos Game")
        settingsViewController.areControlsAffectingSettingsEnabled = true
    }
    
//    // MARK: - Settings UI
//
//    
//    func updateSettingsUI() {
//        vertexCountLabel.text = "\(timedGenerator.generator.polygon.vertices.count)"
//        
//        if isRunning {
//            vertexCountStepper.isEnabled = false
//            toggleGenerationButton.setTitle(NSLocalizedString("Stop", comment: "Title for button that stops point generation"), for: .normal)
//        } else {
//            vertexCountStepper.isEnabled = true
//            toggleGenerationButton.setTitle(NSLocalizedString("Start", comment: "Title for button that starts point generation"), for: .normal)
//        }
//    }
//    
//    
//    // MARK: - Generator UI
//
//    @IBAction func resetGenerator() {
//        if isRunning {
//            toggleGeneration()
//        }
//        
//        timedGenerator = makeGenerator()
//        resetPlotView()
//    }
//    
//    
//    @IBAction func toggleGeneration() {
//        if !isRunning {
//            timedGenerator.start()
//            displayLink.add(to: .current, forMode: .defaultRunLoopMode)
//        } else {
//            timedGenerator.stop()
//            displayLink.remove(from: .current, forMode: .defaultRunLoopMode)
//        }
//        
//        updateSettingsUI()
//    }
//    
//    
//    private func updatePlot(with point: CGPoint) {
//        DispatchQueue.main.async {
//            self.pointPlotView.addPoint(point)
//        }
//    }
//    
//    
//    @objc private func updateIterationLabel() {
//        iterationLabel.text = iterationFormatter.string(from: timedGenerator.generator.iteration as NSNumber)
//    }
}


fileprivate extension CGRect {
    fileprivate static var chaosGameBoundingRect: CGRect {
        return CGRect(x: 0, y: 0, width: 1, height: 1).insetBy(dx: 0.1, dy: 0.1)
    }
}
