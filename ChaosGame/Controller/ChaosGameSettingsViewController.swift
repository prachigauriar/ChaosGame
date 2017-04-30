//
//  ChaosGameSettingsViewController.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
//  Copyright © 2017 Prachi Gauriar. All rights reserved.
//

import Cocoa


public class ChaosGameSettingsViewController : NSViewController, NSTextFieldDelegate {
    public weak var delegate: ChaosGameSettingsViewControllerDelegate?
    
    public var settings: ChaosGameSettings = ChaosGameSettings() {
        didSet {
            if isViewLoaded {
                updateInterface()
            }
        }
    }
    
    private let minimumFrequency: Double = 1
    private let maximumFrequency: Double = 6000
    public var frequency: Double = 1 {
        willSet {
            precondition(newValue >= minimumFrequency && newValue <= maximumFrequency)
        }
        
        didSet {
            if isViewLoaded {
                updateInterface()
            }
        }
    }
    
    
    public var areControlsAffectingSettingsEnabled: Bool = true {
        didSet {
            if isViewLoaded {
                updateInterface()
            }
        }
    }

    
    @IBOutlet weak var vertexCountField: NSTextField!
    @IBOutlet weak var vertexCountStepper: NSStepper!
    @IBOutlet weak var distanceFactorField: NSTextField!
    @IBOutlet weak var vertexSelectionStrategyPopUpButton: NSPopUpButton!
    @IBOutlet weak var frequencySlider: NSSlider!
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        vertexCountStepper.minValue = 3
        vertexCountStepper.maxValue = 20
        
        frequencySlider.minValue = minimumFrequency
        frequencySlider.maxValue = maximumFrequency
        
        updateInterface()
    }

    
    private func updateInterface() {
        vertexCountField.integerValue = settings.polygonVertexCount
        vertexCountStepper.integerValue = settings.polygonVertexCount
        distanceFactorField.doubleValue = settings.distanceFactor
        vertexSelectionStrategyPopUpButton.selectItem(at: settings.vertexSelectionStrategy.rawValue)
        frequencySlider.doubleValue = frequency

        vertexCountField.isEnabled = areControlsAffectingSettingsEnabled
        vertexCountStepper.isEnabled = areControlsAffectingSettingsEnabled
        distanceFactorField.isEnabled = areControlsAffectingSettingsEnabled
        vertexSelectionStrategyPopUpButton.isEnabled = areControlsAffectingSettingsEnabled
    }
    
    
    // MARK: - Actions
    
    @IBAction func takeVertexCount(from control: NSControl) {
        settings.polygonVertexCount = control.integerValue
        notifyDelegateOfSettingsChange()
    }

    
    @IBAction func takeDistanceFactor(from control: NSControl) {
        settings.distanceFactor = control.doubleValue
        notifyDelegateOfSettingsChange()
    }

    
    @IBAction func takeSelectionStrategy(from popUpButton: NSPopUpButton) {
        settings.vertexSelectionStrategy = VertexSelectionStrategy(rawValue: popUpButton.indexOfSelectedItem)!
        notifyDelegateOfSettingsChange()
    }

    
    @IBAction func takeFrequency(from slider: NSSlider) {
        frequency = slider.doubleValue
        notifyDelegateOfFrequencyChange()
    }
    
    
    private func notifyDelegateOfSettingsChange() {
        delegate?.chaosGameSettingsViewController(self, settingsDidChange: settings)
    }


    private func notifyDelegateOfFrequencyChange() {
        delegate?.chaosGameSettingsViewController(self, frequencyDidChange: frequency)
    }
}


public protocol ChaosGameSettingsViewControllerDelegate : class {
    func chaosGameSettingsViewController(_ viewController: ChaosGameSettingsViewController, settingsDidChange settings: ChaosGameSettings)
    func chaosGameSettingsViewController(_ viewController: ChaosGameSettingsViewController, frequencyDidChange frequency: Double)
}
