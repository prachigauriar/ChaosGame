//
//  ChaosGameViewController.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/27/2017.
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


public class ChaosGameViewController : NSViewController, ChaosGameSettingsViewControllerDelegate {
    // Model
    private var gameRunner: ChaosGameRunner?
    private let resolution: CGFloat = 10000
    
    // Controller State
    private var settingsViewController: ChaosGameSettingsViewController!
    private var plotViewController: ChaosGamePlotViewController!
    
    // Views
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var toggleGenerationButton: NSButton!
    
    
    // MARK: - Lifecycle
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "ChaosGameSettingsViewControllerEmbedSegue":
            settingsViewController = segue.destinationController as! ChaosGameSettingsViewController
            settingsViewController.delegate = self
            initializeGameRunner()
        case "ChaosGamePlotViewControllerEmbedSegue":
            plotViewController = segue.destinationController as! ChaosGamePlotViewController
            plotViewController.resolution = resolution
        default:
            break
        }
    }

    
    public override func viewDidDisappear() {
        super.viewDidDisappear()
        
        if gameRunner?.isRunning == true {
            toggleGeneration(nil)
        }
    }

    
    // MARK: - Game Runner
    
    private func initializeGameRunner() {
        updateGameRunner(with: settingsViewController.settings, frequency: settingsViewController.frequency)
    }
    
    
    private func updateGameRunner(with settings: ChaosGameSettings?, frequency: Double) {
        if let settings = settings {
            gameRunner = ChaosGameRunner(settings: settings, boundingRect: .chaosGameBoundingRect(resolution: resolution))
            
            if let plotViewController = plotViewController {
                plotViewController.gameRunner = gameRunner
            }
        }
        
        if let gameRunner = gameRunner {
            gameRunner.generationFrequency = Int(frequency)
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
        initializeGameRunner()
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
}


fileprivate extension CGRect {
    fileprivate static func chaosGameBoundingRect(resolution: CGFloat) -> CGRect {
        let inset = resolution * 0.1
        return CGRect(x: 0, y: 0, width: resolution, height: resolution).insetBy(dx: inset, dy: inset)
    }
}
