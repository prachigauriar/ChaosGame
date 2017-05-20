//
//  ChaosGamePlotViewController.swift
//  ChaosGame
//
//  Created by Prachi Gauriar on 4/29/2017.
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
import SpriteKit


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

    private var interfaceUpdateTimer: QueueTimer?

    private var scene: SKScene = {
        let scene = SKScene(size: CGSize(width: 1000, height: 1000))
        scene.scaleMode = .fill
        scene.backgroundColor = .black
        return scene
    }()
    
    
    // View
    let pointView: SKView = SKView()
    @IBOutlet weak var iterationLabel: NSTextField!
    
    
    // MARK: -

    public override func viewDidLoad() {
        super.viewDidLoad()
        pointView.frame = view.bounds
        pointView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        view.addSubview(pointView, positioned: .below, relativeTo: iterationLabel)
        pointView.presentScene(scene)
    }
    
    
    public func startMonitoringGameRunner() {
        guard gameRunner != nil else {
            return
        }
        
        interfaceUpdateTimer?.invalidate()
        interfaceUpdateTimer = QueueTimer(label: "ChaosGamePlotViewController.interfaceUpdateTimer", interval: 1 / 30) { [unowned self] _ in
            self.updateInterface()
        }
        
        interfaceUpdateTimer?.schedule()
    }
    
    
    public func stopMonitoringGameRunner() {
        interfaceUpdateTimer?.invalidate()
    }
    
    
    public func reset() {
        scene.removeAllChildren()
        
        guard let gameRunner = gameRunner else {
            return
        }
        
        plot(gameRunner.polygon.vertices, color: .blue, diameter: 10)
        plot(gameRunner.allPoints)
        plot([gameRunner.initialPoint], color: .red, diameter: 6)
        iterationLabel.integerValue = gameRunner.iteration
    }

    
    private func updateInterface() {
        guard let gameRunner = gameRunner else {
            return
        }
        
        OperationQueue.main.addOperation {
            self.plot(gameRunner.flushAccumulatedPoints())
            self.iterationLabel.integerValue = gameRunner.iteration
        }
    }
    
    
    private func plot(_ points: [CGPoint], color: NSColor = .white, diameter: CGFloat = 1) {
        for point in points {
            let node = SKSpriteNode(color: color, size: CGSize(width: diameter, height: diameter))
            node.position = point
            scene.addChild(node)
        }
    }
}
